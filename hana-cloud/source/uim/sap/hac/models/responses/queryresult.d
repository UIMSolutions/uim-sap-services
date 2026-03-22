/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.hcd.models.responses.queryresult;

import uim.sap.hcd;

/**
 * Query result set from HANA
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
            return null;
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
