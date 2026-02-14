# UIM SAP HANA Cloud Library

A comprehensive D language library for working with SAP HANA Cloud, built on top of uim-framework and vibe.d.

## Features

- **Full SAP HANA Cloud Support**: Connect and interact with SAP HANA Cloud databases
- **Multiple Authentication Methods**: Basic Auth, OAuth2, JWT, API Key, and Certificate-based authentication
- **SQL Query Builder**: Fluent API for building complex SQL queries
- **Transaction Support**: ACID transaction management
- **Metadata Access**: Retrieve table, view, and column metadata
- **Connection Pooling**: Efficient connection management
- **Error Handling**: Comprehensive exception hierarchy
- **Type-Safe**: Leverages D's type system for safer database operations

## Installation

Add this to your `dub.sdl`:

```sdl
dependency "uim-sap" version="~>1.0.0"
```

Or to your `dub.json`:

```json
{
    "dependencies": {
        "uim-sap": "~>1.0.0"
    }
}
```

## Quick Start

### Basic Connection

```d
import uim.sap;

void main() {
    // Create a client with basic authentication
    auto client = SAPHanaClient.create(
        "myinstance.hanacloud.ondemand.com",
        "mydb",
        "username",
        "password"
    );
    
    // Connect to the database
    client.connect();
    
    // Execute a simple query
    auto result = client.executeQuery("SELECT * FROM DUMMY");
    
    // Close connection
    client.disconnect();
}
```

### Using Query Builder

```d
import uim.sap;

void main() {
    auto client = SAPHanaClient.create("host", "db", "user", "pass");
    client.connect();
    
    // Build a SELECT query
    auto query = QueryBuilder
        .select("id", "name", "email")
        .from("users")
        .where("age", ">", "18")
        .orderBy("name", "ASC")
        .limit(10);
    
    // Execute the query
    auto result = client.execute(query);
    
    // Process results
    foreach (i; 0 .. result.rowCount) {
        auto id = result.getCell(i, "id");
        auto name = result.getCell(i, "name");
        writeln("User: ", name.get!string);
    }
}
```

### Using Transactions

```d
import uim.sap;

void main() {
    auto client = SAPHanaClient.create("host", "db", "user", "pass");
    client.connect();
    
    // Execute within a transaction
    client.transaction({
        client.executeQuery("INSERT INTO users (name) VALUES ('Alice')");
        client.executeQuery("UPDATE accounts SET balance = balance - 100 WHERE user = 'Alice'");
        // Automatically commits on success, rolls back on exception
    });
}
```

## Authentication

### Basic Authentication

```d
auto credential = Credential.basic("username", "password");
auto config = ConnectionConfig.create("host", "db", credential);
auto client = new SAPHanaClient(config);
```

### OAuth2

```d
auto credential = Credential.oauth("clientId", "clientSecret");
auto config = ConnectionConfig.create("host", "db", credential);
auto client = new SAPHanaClient(config);
```

### JWT Token

```d
auto credential = Credential.jwt("your-jwt-token");
auto config = ConnectionConfig.create("host", "db", credential);
auto client = new SAPHanaClient(config);
```

### API Key

```d
auto credential = Credential.apiKey("your-api-key");
auto config = ConnectionConfig.create("host", "db", credential);
auto client = new SAPHanaClient(config);
```

## Advanced Usage

### Custom Configuration

```d
import uim.sap;
import core.time : seconds;

void main() {
    ConnectionConfig config;
    config.host = "myinstance.hanacloud.ondemand.com";
    config.port = 443;
    config.database = "mydb";
    config.useSSL = true;
    config.verifySSL = true;
    config.timeout = 60.seconds;
    config.maxRetries = 3;
    config.credential = Credential.basic("user", "pass");
    config.customHeaders["X-Custom-Header"] = "value";
    
    auto client = new SAPHanaClient(config);
}
```

### Table Metadata

```d
auto client = SAPHanaClient.create("host", "db", "user", "pass");
client.connect();

// Get table metadata
auto metadata = client.getTableMetadata("USERS");
writeln("Table: ", metadata.metadata.name);

foreach (col; metadata.columns) {
    writeln("  Column: ", col.name, " (", col.dataType, ")");
}

// List all tables
auto tables = client.listTables();
foreach (table; tables) {
    writeln("Table: ", table);
}

// List all schemas
auto schemas = client.listSchemas();
```

### Prepared Statements

```d
import vibe.data.json;

auto client = SAPHanaClient.create("host", "db", "user", "pass");
client.connect();

string sql = "SELECT * FROM users WHERE age > ? AND city = ?";
Json[] params = [Json(25), Json("Berlin")];

auto result = client.executePrepared(sql, params);
```

### Batch Execution

```d
auto client = SAPHanaClient.create("host", "db", "user", "pass");
client.connect();

string[] queries = [
    "UPDATE users SET status = 'active' WHERE last_login > '2026-01-01'",
    "DELETE FROM sessions WHERE expired = true",
    "INSERT INTO audit_log (action, timestamp) VALUES ('cleanup', CURRENT_TIMESTAMP)"
];

auto results = client.executeBatch(queries);
```

## Query Builder API

The QueryBuilder provides a fluent interface for constructing SQL queries:

```d
// SELECT query
auto query = QueryBuilder
    .select("u.id", "u.name", "o.total")
    .from("users")
    .leftJoin("orders o", "o.user_id = u.id")
    .where("u.active", "=", "true")
    .andWhere("u.age", ">", "18")
    .orderBy("u.name", "ASC")
    .limit(50)
    .offset(0);

// INSERT query
auto insert = QueryBuilder
    .insert("users")
    .values([
        "name": "John Doe",
        "email": "john@example.com",
        "age": "30"
    ]);

// UPDATE query
auto update = QueryBuilder
    .update("users")
    .set("status", "active")
    .set("updated_at", "CURRENT_TIMESTAMP")
    .where("id", "=", "123");

// DELETE query
auto delete_ = QueryBuilder
    .deleteFrom("users")
    .where("status", "=", "inactive")
    .andWhere("last_login", "<", "2025-01-01");
```

## Error Handling

The library provides a comprehensive exception hierarchy:

```d
import uim.sap;

try {
    auto client = SAPHanaClient.create("host", "db", "user", "pass");
    client.connect();
    auto result = client.executeQuery("SELECT * FROM nonexistent_table");
} catch (SAPAuthenticationException e) {
    writeln("Authentication failed: ", e.msg);
} catch (SAPConnectionException e) {
    writeln("Connection error: ", e.msg);
} catch (SAPQueryException e) {
    writeln("Query error [", e.errorCode, "]: ", e.msg);
} catch (SAPException e) {
    writeln("SAP error: ", e.msg);
}
```

## Development

### Building

```bash
dub build
```

### Testing

```bash
dub test
```

### Documentation

```bash
dub build --build=docs
```

## Requirements

- DMD 2.100+ or LDC 1.30+
- uim-framework ~>26.1.2
- vibe.d ~>0.10.0

## License

Apache-2.0

Copyright © 2018-2026, Ozan Nurettin Süel

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues and questions:
- GitHub Issues: [https://github.com/UIMSolutions/uim-sap/issues](https://github.com/UIMSolutions/uim-sap/issues)
- Website: [https://www.sueel.de/uim/framework](https://www.sueel.de/uim/framework)
