/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.ql.insert;

import uim.sap.service;

/// Fluent builder for CQL INSERT queries.
class CqlInsert {
    private string _entity;
    private Json[] _entries;

    this(string entity) {
        _entity = entity;
    }

    /// Entity name to insert into.
    string entity() const { return _entity; }

    /// The entries to insert.
    Json[] entries() { return _entries; }

    /// Add a single entry (JSON object) to insert.
    CqlInsert entry(Json data) {
        _entries ~= data;
        return this;
    }

    /// Add multiple entries to insert.
    CqlInsert entries_(Json[] data) {
        _entries ~= data;
        return this;
    }
}
