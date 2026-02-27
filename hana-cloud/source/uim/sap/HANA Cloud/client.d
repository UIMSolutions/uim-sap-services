/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.client;

import uim.sap.models;
import uim.sap.auth;
import uim.sap.query;
import uim.sap.exceptions;

import vibe.http.client;
import vibe.data.json;
import vibe.stream.operations;
import std.datetime : Clock;
import std.string : format;
import std.conv : to;
import std.algorithm : map;
import std.array : array;
import core.time : Duration;

/**
 * Main HANA Cloud Client
 */
class HanaClient {
    private ConnectionConfig config;
    private AuthManager authManager;
    private bool connected;
    private string sessionId;
    
    /**
     * Constructor
     */
    this(ConnectionConfig config) {
        this.config = config;
        config.validate();
        this.authManager = new AuthManager(config.credential, config.baseUrl ~ "/oauth/token");
        this.connected = false;
    }
    
    /**
     * Create a client with basic configuration
     */
    static HanaClient create(string host, string database, string username, string password) {
        auto credential = Credential.basic(username, password);
        auto config = ConnectionConfig.create(host, database, credential);
        return new HanaClient(config);
    }
    
    /**
     * Connect to HANA Cloud
     */
    void connect() {
        if (!authManager.validateCredentials()) {
            throw new SAPAuthenticationException("Invalid credentials");
        }
        
        try {
            // Test connection with a simple query
            auto result = executeQuery("SELECT 1 FROM DUMMY");
            connected = true;
        } catch (Exception e) {
            throw new SAPConnectionException("Failed to connect to HANA: " ~ e.msg);
        }
    }
    
    /**
     * Disconnect from HANA Cloud
     */
    void disconnect() {
        connected = false;
        sessionId = null;
    }
    
    /**
     * Check if connected
     */
    @property bool isConnected() const pure nothrow @safe @nogc {
        return connected;
    }
    
    /**
     * Execute a raw SQL query
     */
    QueryResult executeQuery(string sql, Json params = Json.emptyObject) {
        ensureConnected();
        
        auto url = format("%s/sql", config.databaseUrl());
        SAPResponse response = makeRequest(HTTPMethod.POST, url, createQueryPayload(sql, params));
        
        if (!response.isSuccess()) {
            throw new SAPQueryException(response.errorMessage, response.errorCode);
        }
        
        return parseQueryResult(response.data);
    }
    
    /**
     * Execute a query using QueryBuilder
     */
    QueryResult execute(QueryBuilder query) {
        return executeQuery(query.build());
    }
    
    /**
     * Execute multiple statements in a batch
     */
    QueryResult[] executeBatch(string[] sqlStatements) {
        ensureConnected();
        
        QueryResult[] results;
        foreach (sql; sqlStatements) {
            results ~= executeQuery(sql);
        }
        return results;
    }
    
    /**
     * Execute a prepared statement
     */
    QueryResult executePrepared(string sql, Json[] parameters) {
        ensureConnected();
        
        auto url = format("%s/sql/prepared", config.databaseUrl());
        auto payload = Json.emptyObject;
        payload["statement"] = sql;
        payload["parameters"] = Json(parameters);
        
        SAPResponse response = makeRequest(HTTPMethod.POST, url, payload);
        
        if (!response.isSuccess()) {
            throw new SAPQueryException(response.errorMessage, response.errorCode);
        }
        
        return parseQueryResult(response.data);
    }
    
    /**
     * Get table metadata
     */
    TableMetadata getTableMetadata(string tableName, string schema = "") {
        ensureConnected();
        
        string schemaFilter = schema.length > 0 ? schema : config.database;
        
        string sql = format(
            "SELECT * FROM SYS.TABLES WHERE SCHEMA_NAME = '%s' AND TABLE_NAME = '%s'",
            schemaFilter, tableName
        );
        
        auto result = executeQuery(sql);
        
        if (result.rowCount == 0) {
            throw new SAPQueryException(format("Table %s.%s not found", schemaFilter, tableName));
        }
        
        TableMetadata metadata;
        metadata.metadata.schema = schemaFilter;
        metadata.metadata.name = tableName;
        metadata.columns = getColumnMetadata(tableName, schemaFilter);
        
        return metadata;
    }
    
    /**
     * Get column metadata for a table
     */
    ColumnMetadata[] getColumnMetadata(string tableName, string schema = "") {
        ensureConnected();
        
        string schemaFilter = schema.length > 0 ? schema : config.database;
        
        string sql = format(
            "SELECT COLUMN_NAME, DATA_TYPE_NAME, LENGTH, SCALE, IS_NULLABLE " ~
            "FROM SYS.TABLE_COLUMNS " ~
            "WHERE SCHEMA_NAME = '%s' AND TABLE_NAME = '%s' " ~
            "ORDER BY POSITION",
            schemaFilter, tableName
        );
        
        auto result = executeQuery(sql);
        ColumnMetadata[] columns;
        
        for (size_t i = 0; i < result.rowCount; i++) {
            ColumnMetadata col;
            col.name = result.getCell(i, "COLUMN_NAME").get!string;
            col.dataType = result.getCell(i, "DATA_TYPE_NAME").get!string;
            
            auto lengthCell = result.getCell(i, "LENGTH");
            if (lengthCell.type != Json.Type.null_) {
                col.length = lengthCell.get!int;
            }
            
            auto scaleCell = result.getCell(i, "SCALE");
            if (scaleCell.type != Json.Type.null_) {
                col.scale = scaleCell.get!int;
            }
            
            col.nullable = result.getCell(i, "IS_NULLABLE").get!string == "TRUE";
            
            columns ~= col;
        }
        
        return columns;
    }
    
    /**
     * List all tables in the database
     */
    string[] listTables(string schema = "") {
        ensureConnected();
        
        string schemaFilter = schema.length > 0 ? schema : config.database;
        
        string sql = format(
            "SELECT TABLE_NAME FROM SYS.TABLES WHERE SCHEMA_NAME = '%s' ORDER BY TABLE_NAME",
            schemaFilter
        );
        
        auto result = executeQuery(sql);
        string[] tables;
        
        for (size_t i = 0; i < result.rowCount; i++) {
            tables ~= result.getCell(i, "TABLE_NAME").get!string;
        }
        
        return tables;
    }
    
    /**
     * List all views in the database
     */
    string[] listViews(string schema = "") {
        ensureConnected();
        
        string schemaFilter = schema.length > 0 ? schema : config.database;
        
        string sql = format(
            "SELECT VIEW_NAME FROM SYS.VIEWS WHERE SCHEMA_NAME = '%s' ORDER BY VIEW_NAME",
            schemaFilter
        );
        
        auto result = executeQuery(sql);
        string[] views;
        
        for (size_t i = 0; i < result.rowCount; i++) {
            views ~= result.getCell(i, "VIEW_NAME").get!string;
        }
        
        return views;
    }
    
    /**
     * List all schemas
     */
    string[] listSchemas() {
        ensureConnected();
        
        auto result = executeQuery("SELECT SCHEMA_NAME FROM SYS.SCHEMAS ORDER BY SCHEMA_NAME");
        string[] schemas;
        
        for (size_t i = 0; i < result.rowCount; i++) {
            schemas ~= result.getCell(i, "SCHEMA_NAME").get!string;
        }
        
        return schemas;
    }
    
    /**
     * Create a query builder
     */
    QueryBuilder query() {
        return new QueryBuilder();
    }
    
    /**
     * Begin a transaction
     */
    void beginTransaction() {
        executeQuery("BEGIN TRANSACTION");
    }
    
    /**
     * Commit a transaction
     */
    void commit() {
        executeQuery("COMMIT");
    }
    
    /**
     * Rollback a transaction
     */
    void rollback() {
        executeQuery("ROLLBACK");
    }
    
    /**
     * Execute code within a transaction
     */
    void transaction(void delegate() code) {
        beginTransaction();
        try {
            code();
            commit();
        } catch (Exception e) {
            rollback();
            throw e;
        }
    }
    
    /**
     * Get server version information
     */
    string getServerVersion() {
        ensureConnected();
        auto result = executeQuery("SELECT VERSION FROM SYS.M_DATABASE");
        if (result.rowCount > 0) {
            return result.getCell(0, 0).get!string;
        }
        return "Unknown";
    }
    
    /**
     * Ping the server
     */
    bool ping() {
        try {
            executeQuery("SELECT 1 FROM DUMMY");
            return true;
        } catch (Exception) {
            return false;
        }
    }
    
    // Private helper methods
    
    private void ensureConnected() {
        if (!connected) {
            connect();
        }
    }
    
    private Json createQueryPayload(string sql, Json params) {
        auto payload = Json.emptyObject;
        payload["sql"] = sql;
        if (params.type != Json.Type.null_ && params.type != Json.Type.undefined) {
            payload["parameters"] = params;
        }
        return payload;
    }
    
    private SAPResponse makeRequest(HTTPMethod method, string url, Json payload = Json.emptyObject) {
        SAPResponse response;
        response.timestamp = Clock.currTime();
        
        uint retries = 0;
        while (retries <= config.maxRetries) {
            try {
                requestHTTP(url,
                    (scope req) {
                        req.method = method;
                        authManager.addAuthHeaders(req);
                        req.headers["Content-Type"] = "application/json";
                        req.headers["Accept"] = "application/json";
                        
                        // Add custom headers
                        foreach (key, value; config.customHeaders) {
                            req.headers[key] = value;
                        }
                        
                        if (method == HTTPMethod.POST || method == HTTPMethod.PUT) {
                            req.writeJsonBody(payload);
                        }
                    },
                    (scope res) {
                        response.statusCode = res.statusCode;
                        response.success = res.statusCode >= 200 && res.statusCode < 300;
                        
                        // Read response headers
                        foreach (key, value; res.headers) {
                            response.headers[key] = value;
                        }
                        
                        // Read response body
                        if (res.bodyReader.empty) {
                            response.data = Json.emptyObject;
                        } else {
                            try {
                                response.data = res.readJson();
                            } catch (Exception e) {
                                response.data = Json(res.bodyReader.readAllUTF8());
                            }
                        }
                        
                        // Extract error information
                        if (!response.success) {
                            if ("error" in response.data) {
                                if (response.data["error"].type == Json.Type.string) {
                                    response.errorMessage = response.data["error"].get!string;
                                } else if ("message" in response.data["error"]) {
                                    response.errorMessage = response.data["error"]["message"].get!string;
                                }
                                
                                if ("code" in response.data["error"]) {
                                    response.errorCode = response.data["error"]["code"].get!int;
                                }
                            } else if ("message" in response.data) {
                                response.errorMessage = response.data["message"].get!string;
                            }
                        }
                    }
                );
                break;
            } catch (Exception e) {
                retries++;
                if (retries > config.maxRetries) {
                    throw new SAPConnectionException("Request failed after " ~ retries.to!string ~ " retries: " ~ e.msg);
                }
            }
        }
        
        return response;
    }
    
    private QueryResult parseQueryResult(Json data) {
        QueryResult result;
        
        if ("columns" in data) {
            auto cols = data["columns"];
            if (cols.type == Json.Type.array) {
                foreach (col; cols) {
                    result.columns ~= col.get!string;
                }
            }
        }
        
        if ("rows" in data) {
            auto rows = data["rows"];
            if (rows.type == Json.Type.array) {
                foreach (row; rows) {
                    if (row.type == Json.Type.array) {
                        Json[] rowData;
                        foreach (cell; row) {
                            rowData ~= cell;
                        }
                        result.rows ~= rowData;
                    }
                }
            }
        }
        
        result.rowCount = result.rows.length;
        
        if ("executionTime" in data) {
            result.executionTime = data["executionTime"].get!long;
        }
        
        if ("hasMore" in data) {
            result.hasMore = data["hasMore"].get!bool;
        }
        
        if ("cursor" in data) {
            result.nextCursor = data["cursor"].get!string;
        }
        
        return result;
    }
}
