/**
 * Response models for SAP HANA operations
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.models.response;

import vibe.data.json;
import std.datetime : SysTime;

/**
 * Query result set from SAP HANA
 */
struct QueryResult {
    /// Column names in the result set
    string[] columns;
    
    /// Rows of data (each row is an array of JSON values)
    Json[][] rows;
    
    /// Total number of rows
    size_t rowCount;
    
    /// Execution time in milliseconds
    long executionTime;
    
    /// Whether more results are available
    bool hasMore;
    
    /// Cursor for pagination
    string nextCursor;
    
    /**
     * Get a specific row
     */
    Json[] getRow(size_t index) const @safe {
        if (index >= rows.length) {
            return [];
        }
        return rows[index];
    }
    
    /**
     * Get a cell value
     */
    Json getCell(size_t row, size_t col) const @safe {
        if (row >= rows.length || col >= columns.length) {
            return Json(null);
        }
        if (col >= rows[row].length) {
            return Json(null);
        }
        return rows[row][col];
    }
    
    /**
     * Get a cell value by column name
     */
    Json getCell(size_t row, string columnName) const @safe {
        import std.algorithm : countUntil;
        auto colIndex = columns.countUntil(columnName);
        if (colIndex < 0) {
            return Json(null);
        }
        return getCell(row, colIndex);
    }
}

/**
 * SAP HANA API response
 */
struct SAPResponse {
    /// HTTP status code
    int statusCode;
    
    /// Success indicator
    bool success;
    
    /// Response body as JSON
    Json data;
    
    /// Error message if any
    string errorMessage;
    
    /// Error code if any
    int errorCode;
    
    /// Response headers
    string[string] headers;
    
    /// Request timestamp
    SysTime timestamp;
    
    /**
     * Check if the response indicates success
     */
    bool isSuccess() const pure nothrow @safe @nogc {
        return success && statusCode >= 200 && statusCode < 300;
    }
    
    /**
     * Check if the response indicates an error
     */
    bool isError() const pure nothrow @safe @nogc {
        return !success || statusCode >= 400;
    }
}

/**
 * Metadata about a database object
 */
struct ObjectMetadata {
    string schema;
    string name;
    string type; // TABLE, VIEW, PROCEDURE, etc.
    string owner;
    SysTime createdAt;
    SysTime modifiedAt;
    long rowCount;
    long sizeBytes;
    string description;
}

/**
 * Column metadata
 */
struct ColumnMetadata {
    string name;
    string dataType;
    int length;
    int precision;
    int scale;
    bool nullable;
    bool isPrimaryKey;
    bool isForeignKey;
    string defaultValue;
    string comment;
}

/**
 * Table metadata with columns
 */
struct TableMetadata {
    ObjectMetadata metadata;
    ColumnMetadata[] columns;
    string[] primaryKeys;
    string[] indexes;
}
