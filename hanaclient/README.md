# HANA Database Client for D

HANA database client library for D language, built with uim-framework and vibe.d.

## Features

- Connect and health-check HANA
- Execute SQL queries and commands
- Execute batched statements
- Transaction helpers: begin, commit, rollback
- Basic and Bearer authentication
- Typed response models and exception hierarchy

## Installation

For dub.sdl:

```sdl
dependency "uim-sap-hanadb" version="~>1.0.0"
```

For dub.json:

```json
{
  "dependencies": {
    "uim-sap-hanadb": "~>1.0.0"
  }
}
```

## Quick Start

```d
import uim.sap.hanadb;
import vibe.data.json : Json;

void main() {
    auto cfg = HanaDBConfig.createBasic(
        "https://my-hana.example.com",
        "MY_SCHEMA",
        "DBUSER",
        "DBPASSWORD"
    );

    cfg.endpointPath = "/sql";

    auto client = new HanaDBClient(cfg);
    client.connect();

    auto result = client.query("SELECT CURRENT_USER FROM DUMMY");

    Json params = Json.emptyArray;
    params ~= Json("ACTIVE");
    auto filtered = client.query("SELECT * FROM ORDERS WHERE STATUS = ?", params);

    client.disconnect();
}
```
