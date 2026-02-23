/**
 * Utility functions for SAP HANA operations
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.utils;

import std.string : format, join;
import std.algorithm : map;
import std.array : array;
import std.conv : to;

/**
 * Escape a SQL identifier (table name, column name, etc.)
 */
string escapeIdentifier(string identifier) pure @safe {
    import std.string : replace;
    return "\"" ~ identifier.replace("\"", "\"\"") ~ "\"";
}

/**
 * Escape a SQL string value
 */
string escapeString(string value) pure @safe {
    import std.string : replace;
    return value.replace("'", "''");
}

/**
 * Quote a SQL string value
 */
string quoteString(string value) pure @safe {
    return "'" ~ escapeString(value) ~ "'";
}

/**
 * Build a WHERE IN clause
 */
string buildWhereIn(string column, string[] values) pure @safe {
    if (values.length == 0) {
        return "1=0"; // Always false
    }
    
    auto quotedValues = values.map!(v => quoteString(v)).array;
    return format("%s IN (%s)", escapeIdentifier(column), quotedValues.join(", "));
}

/**
 * Build a BETWEEN clause
 */
string buildBetween(string column, string min, string max) pure @safe {
    return format("%s BETWEEN %s AND %s",
        escapeIdentifier(column),
        quoteString(min),
        quoteString(max));
}

/**
 * Build a LIKE clause with wildcards
 */
string buildLike(string column, string pattern, bool caseInsensitive = false) pure @safe {
    auto op = caseInsensitive ? "ILIKE" : "LIKE";
    return format("%s %s %s", escapeIdentifier(column), op, quoteString(pattern));
}

/**
 * Convert D type name to SAP HANA SQL type
 */
string toSQLType(string dType) pure @safe {
    switch (dType) {
        case "bool":
            return "BOOLEAN";
        case "byte", "ubyte":
            return "TINYINT";
        case "short", "ushort":
            return "SMALLINT";
        case "int", "uint":
            return "INTEGER";
        case "long", "ulong":
            return "BIGINT";
        case "float":
            return "REAL";
        case "double":
            return "DOUBLE";
        case "string":
            return "NVARCHAR(5000)";
        case "DateTime", "SysTime":
            return "TIMESTAMP";
        case "Date":
            return "DATE";
        case "TimeOfDay":
            return "TIME";
        default:
            return "NVARCHAR(5000)";
    }
}

/**
 * Generate CREATE TABLE statement from column definitions
 */
string generateCreateTable(string tableName, string[string] columns, string[] primaryKeys = []) pure @safe {
    import std.algorithm : canFind;
    
    string[] columnDefs;
    foreach (name, type; columns) {
        string def = format("%s %s", escapeIdentifier(name), type);
        if (primaryKeys.canFind(name)) {
            def ~= " PRIMARY KEY";
        }
        columnDefs ~= def;
    }
    
    return format("CREATE TABLE %s (%s)", escapeIdentifier(tableName), columnDefs.join(", "));
}

/**
 * Generate DROP TABLE statement
 */
string generateDropTable(string tableName, bool ifExists = true) pure @safe {
    if (ifExists) {
        return format("DROP TABLE IF EXISTS %s", escapeIdentifier(tableName));
    }
    return format("DROP TABLE %s", escapeIdentifier(tableName));
}

/**
 * Generate CREATE INDEX statement
 */
string generateCreateIndex(string indexName, string tableName, string[] columns, bool unique = false) pure @safe {
    auto uniqueStr = unique ? "UNIQUE " : "";
    auto columnList = columns.map!(c => escapeIdentifier(c)).join(", ");
    return format("CREATE %sINDEX %s ON %s (%s)",
        uniqueStr,
        escapeIdentifier(indexName),
        escapeIdentifier(tableName),
        columnList);
}

/**
 * Generate ALTER TABLE ADD COLUMN statement
 */
string generateAddColumn(string tableName, string columnName, string dataType) pure @safe {
    return format("ALTER TABLE %s ADD (%s %s)",
        escapeIdentifier(tableName),
        escapeIdentifier(columnName),
        dataType);
}

/**
 * Generate ALTER TABLE DROP COLUMN statement
 */
string generateDropColumn(string tableName, string columnName) pure @safe {
    return format("ALTER TABLE %s DROP (%s)",
        escapeIdentifier(tableName),
        escapeIdentifier(columnName));
}

/**
 * Build pagination clause
 */
string buildPagination(uint page, uint pageSize) pure @safe {
    auto offset = (page - 1) * pageSize;
    return format("LIMIT %d OFFSET %d", pageSize, offset);
}

/**
 * Build full-text search clause for SAP HANA
 */
string buildFullTextSearch(string[] columns, string searchTerm) pure @safe {
    auto columnList = columns.map!(c => escapeIdentifier(c)).join(", ");
    return format("CONTAINS((%s), %s)", columnList, quoteString(searchTerm));
}

/**
 * Format timestamp for SAP HANA
 */
string formatTimestamp(string timestamp) pure @safe {
    return format("TO_TIMESTAMP(%s, 'YYYY-MM-DD HH24:MI:SS')", quoteString(timestamp));
}

/**
 * Format date for SAP HANA
 */
string formatDate(string date) pure @safe {
    return format("TO_DATE(%s, 'YYYY-MM-DD')", quoteString(date));
}

/**
 * Build CASE WHEN statement
 */
string buildCaseWhen(string[string] conditions, string defaultValue = "NULL") pure @safe {
    string[] cases;
    foreach (condition, value; conditions) {
        cases ~= format("WHEN %s THEN %s", condition, value);
    }
    return format("CASE %s ELSE %s END", cases.join(" "), defaultValue);
}

/**
 * Build COALESCE expression
 */
string buildCoalesce(string[] expressions...) pure @safe {
    return format("COALESCE(%s)", expressions.join(", "));
}

/**
 * Build aggregate function
 */
string buildAggregate(string function_, string column, string alias = "") pure @safe {
    auto expr = format("%s(%s)", function_, escapeIdentifier(column));
    if (alias.length > 0) {
        expr ~= " AS " ~ escapeIdentifier(alias);
    }
    return expr;
}

/**
 * Validate SQL identifier (table name, column name, etc.)
 */
bool isValidIdentifier(string identifier) pure @safe {
    import std.ascii : isAlpha, isAlphaNum;
    
    if (identifier.length == 0) {
        return false;
    }
    
    // Must start with letter or underscore
    if (!isAlpha(identifier[0]) && identifier[0] != '_') {
        return false;
    }
    
    // Rest must be alphanumeric or underscore
    foreach (c; identifier[1..$]) {
        if (!isAlphaNum(c) && c != '_') {
            return false;
        }
    }
    
    return true;
}
