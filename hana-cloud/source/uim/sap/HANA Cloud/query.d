/**
 * SQL Query builder for SAP HANA
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.query;

import std.string : format, join;
import std.array : array, Appender;
import std.algorithm : map;
import std.conv : to;

/**
 * Query types
 */
enum QueryType {
    Select,
    Insert,
    Update,
    Delete,
    CreateTable,
    DropTable,
    AlterTable,
    CreateView,
    DropView
}

/**
 * SQL Query Builder for SAP HANA
 */
class QueryBuilder {
    private QueryType queryType;
    private string tableName;
    private string[] selectColumns;
    private string[string] insertValues;
    private string[string] updateValues;
    private string[] whereConditions;
    private string[] joinClauses;
    private string[] orderByColumns;
    private string[] groupByColumns;
    private string havingCondition;
    private int limitValue = -1;
    private int offsetValue = -1;
    private string schemaName;
    
    /**
     * Start a SELECT query
     */
    static QueryBuilder select(string[] columns...) {
        auto qb = new QueryBuilder();
        qb.queryType = QueryType.Select;
        qb.selectColumns = columns.dup;
        return qb;
    }
    
    /**
     * Start an INSERT query
     */
    static QueryBuilder insert(string table) {
        auto qb = new QueryBuilder();
        qb.queryType = QueryType.Insert;
        qb.tableName = table;
        return qb;
    }
    
    /**
     * Start an UPDATE query
     */
    static QueryBuilder update(string table) {
        auto qb = new QueryBuilder();
        qb.queryType = QueryType.Update;
        qb.tableName = table;
        return qb;
    }
    
    /**
     * Start a DELETE query
     */
    static QueryBuilder deleteFrom(string table) {
        auto qb = new QueryBuilder();
        qb.queryType = QueryType.Delete;
        qb.tableName = table;
        return qb;
    }
    
    /**
     * Set the schema
     */
    QueryBuilder schema(string schema) {
        this.schemaName = schema;
        return this;
    }
    
    /**
     * Set FROM clause
     */
    QueryBuilder from(string table) {
        this.tableName = table;
        return this;
    }
    
    /**
     * Add WHERE condition
     */
    QueryBuilder where(string condition) {
        whereConditions ~= condition;
        return this;
    }
    
    /**
     * Add WHERE condition with parameter
     */
    QueryBuilder where(string column, string operator, string value) {
        whereConditions ~= format("%s %s '%s'", column, operator, escapeSql(value));
        return this;
    }
    
    /**
     * Add AND WHERE condition
     */
    QueryBuilder andWhere(string condition) {
        return where(condition);
    }
    
    /**
     * Add OR WHERE condition
     */
    QueryBuilder orWhere(string condition) {
        if (whereConditions.length > 0) {
            whereConditions[$ - 1] = format("(%s) OR (%s)", whereConditions[$ - 1], condition);
        } else {
            whereConditions ~= condition;
        }
        return this;
    }
    
    /**
     * Add JOIN clause
     */
    QueryBuilder join(string table, string condition) {
        joinClauses ~= format("JOIN %s ON %s", table, condition);
        return this;
    }
    
    /**
     * Add LEFT JOIN clause
     */
    QueryBuilder leftJoin(string table, string condition) {
        joinClauses ~= format("LEFT JOIN %s ON %s", table, condition);
        return this;
    }
    
    /**
     * Add RIGHT JOIN clause
     */
    QueryBuilder rightJoin(string table, string condition) {
        joinClauses ~= format("RIGHT JOIN %s ON %s", table, condition);
        return this;
    }
    
    /**
     * Add ORDER BY clause
     */
    QueryBuilder orderBy(string column, string direction = "ASC") {
        orderByColumns ~= format("%s %s", column, direction);
        return this;
    }
    
    /**
     * Add GROUP BY clause
     */
    QueryBuilder groupBy(string[] columns...) {
        groupByColumns ~= columns;
        return this;
    }
    
    /**
     * Add HAVING clause
     */
    QueryBuilder having(string condition) {
        havingCondition = condition;
        return this;
    }
    
    /**
     * Set LIMIT
     */
    QueryBuilder limit(int limit) {
        this.limitValue = limit;
        return this;
    }
    
    /**
     * Set OFFSET
     */
    QueryBuilder offset(int offset) {
        this.offsetValue = offset;
        return this;
    }
    
    /**
     * Set values for INSERT
     */
    QueryBuilder values(string[string] values) {
        this.insertValues = values;
        return this;
    }
    
    /**
     * Set values for UPDATE
     */
    QueryBuilder set(string[string] values) {
        this.updateValues = values;
        return this;
    }
    
    /**
     * Set a single value for UPDATE
     */
    QueryBuilder set(string column, string value) {
        this.updateValues[column] = value;
        return this;
    }
    
    /**
     * Build the final SQL query
     */
    string build() {
        final switch (queryType) {
            case QueryType.Select:
                return buildSelect();
            case QueryType.Insert:
                return buildInsert();
            case QueryType.Update:
                return buildUpdate();
            case QueryType.Delete:
                return buildDelete();
            case QueryType.CreateTable:
            case QueryType.DropTable:
            case QueryType.AlterTable:
            case QueryType.CreateView:
            case QueryType.DropView:
                return ""; // Not implemented yet
        }
    }
    
    /**
     * Build SELECT query
     */
    private string buildSelect() {
        Appender!string query;
        
        // SELECT
        query ~= "SELECT ";
        if (selectColumns.length > 0) {
            query ~= selectColumns.join(", ");
        } else {
            query ~= "*";
        }
        
        // FROM
        if (tableName.length > 0) {
            query ~= " FROM ";
            if (schemaName.length > 0) {
                query ~= format("%s.%s", schemaName, tableName);
            } else {
                query ~= tableName;
            }
        }
        
        // JOINs
        if (joinClauses.length > 0) {
            query ~= " ";
            query ~= joinClauses.join(" ");
        }
        
        // WHERE
        if (whereConditions.length > 0) {
            query ~= " WHERE ";
            query ~= whereConditions.join(" AND ");
        }
        
        // GROUP BY
        if (groupByColumns.length > 0) {
            query ~= " GROUP BY ";
            query ~= groupByColumns.join(", ");
        }
        
        // HAVING
        if (havingCondition.length > 0) {
            query ~= " HAVING ";
            query ~= havingCondition;
        }
        
        // ORDER BY
        if (orderByColumns.length > 0) {
            query ~= " ORDER BY ";
            query ~= orderByColumns.join(", ");
        }
        
        // LIMIT
        if (limitValue > 0) {
            query ~= format(" LIMIT %d", limitValue);
        }
        
        // OFFSET
        if (offsetValue > 0) {
            query ~= format(" OFFSET %d", offsetValue);
        }
        
        return query.data;
    }
    
    /**
     * Build INSERT query
     */
    private string buildInsert() {
        if (insertValues.length == 0) {
            return "";
        }
        
        auto columns = insertValues.keys;
        auto values = columns.map!(k => format("'%s'", escapeSql(insertValues[k]))).array;
        
        string fullTableName = tableName;
        if (schemaName.length > 0) {
            fullTableName = format("%s.%s", schemaName, tableName);
        }
        
        return format("INSERT INTO %s (%s) VALUES (%s)",
            fullTableName,
            columns.join(", "),
            values.join(", "));
    }
    
    /**
     * Build UPDATE query
     */
    private string buildUpdate() {
        if (updateValues.length == 0) {
            return "";
        }
        
        Appender!string query;
        
        string fullTableName = tableName;
        if (schemaName.length > 0) {
            fullTableName = format("%s.%s", schemaName, tableName);
        }
        
        query ~= format("UPDATE %s SET ", fullTableName);
        
        auto setClauses = updateValues.keys.map!(k =>
            format("%s = '%s'", k, escapeSql(updateValues[k]))).array;
        query ~= setClauses.join(", ");
        
        if (whereConditions.length > 0) {
            query ~= " WHERE ";
            query ~= whereConditions.join(" AND ");
        }
        
        return query.data;
    }
    
    /**
     * Build DELETE query
     */
    private string buildDelete() {
        Appender!string query;
        
        string fullTableName = tableName;
        if (schemaName.length > 0) {
            fullTableName = format("%s.%s", schemaName, tableName);
        }
        
        query ~= format("DELETE FROM %s", fullTableName);
        
        if (whereConditions.length > 0) {
            query ~= " WHERE ";
            query ~= whereConditions.join(" AND ");
        }
        
        return query.data;
    }
    
    /**
     * Escape SQL string
     */
    private static string escapeSql(string value) {
        import std.string : replace;
        return value.replace("'", "''");
    }
    
    /**
     * Convert to string
     */
    override string toString() {
        return build();
    }
}
