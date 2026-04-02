/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.db.memory;

import uim.sap.cap.cds.model;
import uim.sap.cap.cds.entity;
import uim.sap.cap.ql.filter;
import uim.sap.cap.ql.select;
import uim.sap.cap.ql.insert;
import uim.sap.cap.ql.update;
import uim.sap.cap.ql.delete_;
import uim.sap.cap.db.database;
import uim.sap.service;

import core.sync.mutex;
import std.algorithm : min;
import std.conv : to;
import std.string : toLower;

/// In-memory database implementation for testing, development, and mock mode.
/// Thread-safe via Mutex. Data is stored as Json arrays per entity.
class InMemoryDatabase : DatabaseService {
    private Json[][string] _tables;    /// entity name → rows
    private CdsModel _model;
    private Mutex _lock;

    this() {
        _lock = new Mutex();
    }

    /// Deploy the CDS model — initializes empty tables for each entity.
    void deploy(CdsModel model) {
        _lock.lock();
        scope(exit) _lock.unlock();
        _model = model;
        foreach (name; model.entityNames()) {
            if (name !in _tables)
                _tables[name] = [];
        }
    }

    /// Execute a SELECT query.
    Json run(CqlSelect query) {
        _lock.lock();
        scope(exit) _lock.unlock();

        auto entityName = query.entity;
        if (entityName !in _tables)
            return Json.emptyArray;

        Json[] rows = _tables[entityName];

        // Apply WHERE filters
        auto predicates = query.predicates;
        if (predicates.length > 0) {
            Json[] filtered;
            foreach (row; rows) {
                if (matchesAll(row, predicates))
                    filtered ~= row;
            }
            rows = filtered;
        }

        auto totalCount = rows.length;

        // Apply ORDER BY
        auto orderFields = query.orderByFields;
        if (orderFields.length > 0) {
            // Simple single-field sort
            auto fieldName = orderFields[0];
            auto desc = query.orderByDescending.length > 0 ? query.orderByDescending[0] : false;
            rows = sortRows(rows, fieldName, desc);
        }

        // Apply offset and limit
        auto offsetVal = query.offset;
        if (offsetVal > 0 && offsetVal < rows.length) {
            rows = rows[offsetVal .. $];
        } else if (offsetVal >= rows.length) {
            rows = [];
        }

        auto limitVal = query.limit;
        if (limitVal >= 0 && limitVal < rows.length) {
            rows = rows[0 .. limitVal];
        }

        // Apply column projection
        auto cols = query.columns;
        if (cols.length > 0) {
            Json[] projected;
            foreach (row; rows) {
                projected ~= projectColumns(row, cols);
            }
            rows = projected;
        }

        // Single read (byId)
        if (query.isSingleRead) {
            if (rows.length > 0)
                return rows[0];
            return Json(null);
        }

        // Build result
        auto result = Json.emptyObject;
        auto arr = Json.emptyArray;
        foreach (row; rows)
            arr ~= row;
        result["value"] = arr;

        if (query.countRequested)
            result["@odata.count"] = Json(cast(long) totalCount);

        return result;
    }

    /// Execute an INSERT query.
    Json run(CqlInsert query) {
        _lock.lock();
        scope(exit) _lock.unlock();

        auto entityName = query.entity;
        if (entityName !in _tables)
            _tables[entityName] = [];

        Json[] inserted;
        foreach (entry; query.entries) {
            // Auto-generate ID if not provided and entity has UUID key
            auto row = entry;
            if (_model !is null) {
                auto entDef = _model.getEntity(entityName);
                if (entDef !is null) {
                    auto keyFields = entDef.keyFieldNames();
                    foreach (keyField; keyFields) {
                        if (row[keyField].type == Json.Type.undefined ||
                            row[keyField].type == Json.Type.null_) {
                            row[keyField] = Json(createId());
                        }
                    }
                }
            }
            _tables[entityName] ~= row;
            inserted ~= row;
        }

        if (inserted.length == 1)
            return inserted[0];

        auto arr = Json.emptyArray;
        foreach (entry; inserted)
            arr ~= entry;
        return arr;
    }

    /// Execute an UPDATE query. Returns count of affected rows.
    Json run(CqlUpdate query) {
        _lock.lock();
        scope(exit) _lock.unlock();

        auto entityName = query.entity;
        if (entityName !in _tables)
            return Json.emptyObject.set("affected", 0);

        auto predicates = query.predicates;
        auto updateData = query.data;
        int affected = 0;

        foreach (ref row; _tables[entityName]) {
            if (matchesAll(row, predicates)) {
                // Merge update data into the existing row
                foreach (string key, Json value; updateData) {
                    row[key] = value;
                }
                affected++;
            }
        }

        return Json.emptyObject.set("affected", affected);
    }

    /// Execute a DELETE query. Returns count of deleted rows.
    Json run(CqlDelete query) {
        _lock.lock();
        scope(exit) _lock.unlock();

        auto entityName = query.entity;
        if (entityName !in _tables)
            return Json.emptyObject.set("affected", 0);

        auto predicates = query.predicates;
        Json[] remaining;
        int deleted = 0;

        foreach (row; _tables[entityName]) {
            if (matchesAll(row, predicates)) {
                deleted++;
            } else {
                remaining ~= row;
            }
        }

        _tables[entityName] = remaining;
        return Json.emptyObject.set("affected", deleted);
    }

    /// Check if a row matches all predicates.
    private bool matchesAll(Json row, const CqlPredicate[] predicates) {
        foreach (pred; predicates) {
            if (!matchesPredicate(row, pred))
                return false;
        }
        return true;
    }

    /// Evaluate a single predicate against a row.
    private bool matchesPredicate(Json row, const CqlPredicate pred) {
        auto fieldVal = row[pred.field];

        if (fieldVal.type == Json.Type.undefined || fieldVal.type == Json.Type.null_) {
            return pred.op == Op.IS_NULL;
        }

        auto fieldStr = fieldVal.type == Json.Type.string
            ? fieldVal.get!string
            : fieldVal.to!string;
        auto predValue = pred.value;

        final switch (pred.op) {
            case Op.EQ:          return fieldStr == predValue;
            case Op.NE:          return fieldStr != predValue;
            case Op.GT:          return compareNumeric(fieldStr, predValue) > 0;
            case Op.GE:          return compareNumeric(fieldStr, predValue) >= 0;
            case Op.LT:          return compareNumeric(fieldStr, predValue) < 0;
            case Op.LE:          return compareNumeric(fieldStr, predValue) <= 0;
            case Op.LIKE:        return matchesLike(fieldStr, predValue);
            case Op.IN:          return false; // TODO: implement IN with value list
            case Op.BETWEEN:     return compareNumeric(fieldStr, pred.value) >= 0
                                     && compareNumeric(fieldStr, pred.value2) <= 0;
            case Op.IS_NULL:     return false; // Already handled above
            case Op.IS_NOT_NULL: return true;  // Already handled above
        }
    }

    /// Numeric comparison with fallback to string comparison.
    private int compareNumeric(string a, string b) {
        try {
            auto da = a.to!double;
            auto db = b.to!double;
            return da < db ? -1 : (da > db ? 1 : 0);
        } catch (Exception) {
            return a < b ? -1 : (a > b ? 1 : 0);
        }
    }

    /// Simple LIKE pattern matching (% as wildcard).
    private bool matchesLike(string value, string pattern) {
        auto lowerVal = toLower(value);
        auto lowerPat = toLower(pattern);

        if (lowerPat.length == 0)
            return lowerVal.length == 0;

        // Handle leading/trailing % wildcards
        if (lowerPat[0] == '%' && lowerPat[$ - 1] == '%' && lowerPat.length > 1) {
            import std.string : indexOf;
            return lowerVal.indexOf(lowerPat[1 .. $ - 1]) >= 0;
        }
        if (lowerPat[0] == '%') {
            auto suffix = lowerPat[1 .. $];
            return lowerVal.length >= suffix.length
                && lowerVal[$ - suffix.length .. $] == suffix;
        }
        if (lowerPat[$ - 1] == '%') {
            auto prefix = lowerPat[0 .. $ - 1];
            return lowerVal.length >= prefix.length
                && lowerVal[0 .. prefix.length] == prefix;
        }

        return lowerVal == lowerPat;
    }

    /// Sort rows by a field name.
    private Json[] sortRows(Json[] rows, string field, bool desc) {
        import std.algorithm : sort;
        import std.array : array;

        auto sorted = rows.array;
        sorted.sort!((a, b) {
            auto va = a[field];
            auto vb = b[field];
            string sa = va.type == Json.Type.string ? va.get!string : va.to!string;
            string sb = vb.type == Json.Type.string ? vb.get!string : vb.to!string;
            return desc ? sa > sb : sa < sb;
        });
        return sorted;
    }

    /// Project specific columns from a row.
    private Json projectColumns(Json row, string[] cols) {
        auto projected = Json.emptyObject;
        foreach (col; cols) {
            auto val = row[col];
            if (val.type != Json.Type.undefined)
                projected[col] = val;
        }
        return projected;
    }
}
