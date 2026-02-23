/**
 * Example usage of UIM SAP HANA Cloud Library
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
import uim.sap;
import std.stdio : writeln, writefln;
import vibe.data.json;

void main() {
    writeln("=== UIM SAP HANA Cloud Library Examples ===\n");
    
    // Example 1: Basic Connection
    basicConnectionExample();
    
    // Example 2: Query Builder
    queryBuilderExample();
    
    // Example 3: Transaction Management
    transactionExample();
    
    // Example 4: Metadata Operations
    metadataExample();
}

void basicConnectionExample() {
    writeln("--- Example 1: Basic Connection ---");
    
    try {
        // Create client with basic authentication
        auto client = SAPHanaClient.create(
            "myinstance.hanacloud.ondemand.com",
            "MYDB",
            "username",
            "password"
        );
        
        // Connect to the database
        client.connect();
        writeln("✓ Connected to SAP HANA Cloud");
        
        // Check connection
        if (client.ping()) {
            writeln("✓ Server is responding");
        }
        
        // Get server version
        auto version_ = client.getServerVersion();
        writeln("Server version: ", version_);
        
        // Execute a simple query
        auto result = client.executeQuery("SELECT 'Hello from SAP HANA!' AS greeting FROM DUMMY");
        
        if (result.rowCount > 0) {
            auto greeting = result.getCell(0, "greeting");
            writeln("Query result: ", greeting.get!string);
        }
        
        // Disconnect
        client.disconnect();
        writeln("✓ Disconnected\n");
        
    } catch (SAPException e) {
        writeln("✗ Error: ", e.msg);
    }
}

void queryBuilderExample() {
    writeln("--- Example 2: Query Builder ---");
    
    try {
        auto client = SAPHanaClient.create("host", "db", "user", "pass");
        client.connect();
        
        // Build a SELECT query
        auto selectQuery = QueryBuilder
            .select("id", "name", "email", "created_at")
            .from("users")
            .where("status", "=", "active")
            .andWhere("age", ">=", "18")
            .orderBy("created_at", "DESC")
            .limit(10);
        
        writeln("Generated SQL:");
        writeln(selectQuery.build());
        writeln();
        
        // Build an INSERT query
        auto insertQuery = QueryBuilder
            .insert("users")
            .values([
                "name": "Alice Smith",
                "email": "alice@example.com",
                "age": "28",
                "status": "active"
            ]);
        
        writeln("Insert SQL:");
        writeln(insertQuery.build());
        writeln();
        
        // Build an UPDATE query
        auto updateQuery = QueryBuilder
            .update("users")
            .set("last_login", "CURRENT_TIMESTAMP")
            .set("login_count", "login_count + 1")
            .where("id", "=", "123");
        
        writeln("Update SQL:");
        writeln(updateQuery.build());
        writeln();
        
        // Build a DELETE query
        auto deleteQuery = QueryBuilder
            .deleteFrom("sessions")
            .where("expired", "=", "true")
            .andWhere("created_at", "<", "2026-01-01");
        
        writeln("Delete SQL:");
        writeln(deleteQuery.build());
        writeln();
        
        // Complex JOIN query
        auto joinQuery = QueryBuilder
            .select("u.id", "u.name", "COUNT(o.id) as order_count", "SUM(o.total) as total_spent")
            .from("users u")
            .leftJoin("orders o", "o.user_id = u.id")
            .where("u.status", "=", "active")
            .groupBy("u.id", "u.name")
            .having("COUNT(o.id) > 5")
            .orderBy("total_spent", "DESC")
            .limit(20);
        
        writeln("Complex JOIN query:");
        writeln(joinQuery.build());
        writeln();
        
        client.disconnect();
        
    } catch (SAPException e) {
        writeln("✗ Error: ", e.msg);
    }
}

void transactionExample() {
    writeln("--- Example 3: Transaction Management ---");
    
    try {
        auto client = SAPHanaClient.create("host", "db", "user", "pass");
        client.connect();
        
        writeln("Starting transaction...");
        
        // Execute multiple operations in a transaction
        client.transaction({
            // Deduct from sender's account
            client.executeQuery(
                "UPDATE accounts SET balance = balance - 100 WHERE user_id = 1"
            );
            
            // Add to receiver's account
            client.executeQuery(
                "UPDATE accounts SET balance = balance + 100 WHERE user_id = 2"
            );
            
            // Log the transaction
            client.executeQuery(
                "INSERT INTO transaction_log (from_user, to_user, amount, timestamp) " ~
                "VALUES (1, 2, 100, CURRENT_TIMESTAMP)"
            );
            
            writeln("✓ Transaction committed successfully");
        });
        
        // Manual transaction control
        writeln("\nManual transaction control:");
        client.beginTransaction();
        
        try {
            client.executeQuery("UPDATE users SET status = 'inactive' WHERE last_login < '2025-01-01'");
            client.executeQuery("INSERT INTO audit_log (action) VALUES ('user_cleanup')");
            client.commit();
            writeln("✓ Manual transaction committed");
        } catch (Exception e) {
            client.rollback();
            writeln("✗ Transaction rolled back: ", e.msg);
        }
        
        client.disconnect();
        writeln();
        
    } catch (SAPException e) {
        writeln("✗ Error: ", e.msg);
    }
}

void metadataExample() {
    writeln("--- Example 4: Metadata Operations ---");
    
    try {
        auto client = SAPHanaClient.create("host", "db", "user", "pass");
        client.connect();
        
        // List all schemas
        writeln("Available schemas:");
        auto schemas = client.listSchemas();
        foreach (schema; schemas) {
            writeln("  - ", schema);
        }
        writeln();
        
        // List all tables in a schema
        writeln("Tables in database:");
        auto tables = client.listTables("MYSCHEMA");
        foreach (table; tables) {
            writeln("  - ", table);
        }
        writeln();
        
        // List all views
        writeln("Views in database:");
        auto views = client.listViews("MYSCHEMA");
        foreach (view; views) {
            writeln("  - ", view);
        }
        writeln();
        
        // Get detailed table metadata
        writeln("Table metadata for 'USERS':");
        auto metadata = client.getTableMetadata("USERS", "MYSCHEMA");
        writefln("  Schema: %s", metadata.metadata.schema);
        writefln("  Name: %s", metadata.metadata.name);
        writeln("  Columns:");
        
        foreach (col; metadata.columns) {
            writefln("    - %s: %s%s%s",
                col.name,
                col.dataType,
                col.length > 0 ? "(" ~ col.length.to!string ~ ")" : "",
                col.nullable ? " NULL" : " NOT NULL"
            );
        }
        writeln();
        
        // Get column metadata
        writeln("Column details:");
        auto columns = client.getColumnMetadata("USERS", "MYSCHEMA");
        foreach (col; columns) {
            writefln("  %s: %s", col.name, col.dataType);
        }
        writeln();
        
        client.disconnect();
        
    } catch (SAPException e) {
        writeln("✗ Error: ", e.msg);
    }
}

void authenticationExample() {
    writeln("--- Example 5: Different Authentication Methods ---");
    
    // Basic Authentication
    {
        auto credential = Credential.basic("username", "password");
        auto config = ConnectionConfig.create("host", "db", credential);
        auto client = new SAPHanaClient(config);
        writeln("✓ Basic Auth configured");
    }
    
    // OAuth2
    {
        auto credential = Credential.oauth("clientId", "clientSecret");
        auto config = ConnectionConfig.create("host", "db", credential);
        auto client = new SAPHanaClient(config);
        writeln("✓ OAuth2 configured");
    }
    
    // JWT
    {
        auto credential = Credential.jwt("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...");
        auto config = ConnectionConfig.create("host", "db", credential);
        auto client = new SAPHanaClient(config);
        writeln("✓ JWT configured");
    }
    
    // API Key
    {
        auto credential = Credential.apiKey("your-api-key-here");
        auto config = ConnectionConfig.create("host", "db", credential);
        auto client = new SAPHanaClient(config);
        writeln("✓ API Key configured");
    }
    
    writeln();
}

void preparedStatementsExample() {
    writeln("--- Example 6: Prepared Statements ---");
    
    try {
        auto client = SAPHanaClient.create("host", "db", "user", "pass");
        client.connect();
        
        // Prepare a query with parameters
        string sql = "SELECT * FROM users WHERE age > ? AND city = ? AND status = ?";
        
        Json[] params = [
            Json(25),
            Json("Berlin"),
            Json("active")
        ];
        
        writeln("Executing prepared statement...");
        auto result = client.executePrepared(sql, params);
        
        writefln("Found %d matching users", result.rowCount);
        
        // Process results
        for (size_t i = 0; i < result.rowCount; i++) {
            auto row = result.getRow(i);
            writeln("  User: ", row);
        }
        
        client.disconnect();
        writeln();
        
    } catch (SAPException e) {
        writeln("✗ Error: ", e.msg);
    }
}

void batchExecutionExample() {
    writeln("--- Example 7: Batch Execution ---");
    
    try {
        auto client = SAPHanaClient.create("host", "db", "user", "pass");
        client.connect();
        
        string[] queries = [
            "UPDATE users SET status = 'verified' WHERE email_verified = true",
            "DELETE FROM sessions WHERE expired_at < CURRENT_TIMESTAMP",
            "INSERT INTO audit_log (action, timestamp) VALUES ('cleanup', CURRENT_TIMESTAMP)",
            "UPDATE statistics SET last_updated = CURRENT_TIMESTAMP"
        ];
        
        writeln("Executing batch of ", queries.length, " queries...");
        auto results = client.executeBatch(queries);
        
        writefln("✓ Executed %d queries successfully", results.length);
        
        client.disconnect();
        writeln();
        
    } catch (SAPException e) {
        writeln("✗ Error: ", e.msg);
    }
}
