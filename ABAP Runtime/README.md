# UIM SAP ABAP Runtime (ART)

SAP ABAP Runtime implementation in D language using `uim-framework` and `vibe.d`.

This package provides a lightweight ABAP-like runtime host where you can:

- register ABAP-style programs (`Z_*`) as D handlers,
- execute them over HTTP,
- expose runtime health and program catalog endpoints.

## Features

- Program registry for ABAP-style runtime handlers
- Runtime execution API with typed request/response models
- HTTP endpoints via `vibe.d`
- Optional bearer-token protection for runtime execution
- Minimal integration surface for embedding in SAP-adjacent services

## Installation

Add this to your `dub.sdl`:

```sdl
dependency "uim-sap-art" version="~>1.0.0"
```

## Quick Start

```d
import vibe.data.json : Json;
import uim.sap.art;

void main() {
    SAPABAPRuntimeConfig config;
    config.host = "127.0.0.1";
    config.port = 8080;
    config.basePath = "/sap/abap/runtime";

    auto runtime = new SAPABAPRuntime(config);

    runtime.registerProgram("Z_HELLO_WORLD", (request) {
        Json data = Json.emptyObject;
        data["message"] = "Hello from ABAP Runtime";
        return successResult("OK", data);
    });

    auto server = new SAPABAPRuntimeServer(runtime);
    server.run();
}
```

## HTTP API

Base path is configurable (default: `/sap/abap/runtime`).

- `GET /sap/abap/runtime/health`
- `GET /sap/abap/runtime/programs`
- `POST /sap/abap/runtime/run`

### Run Program Request

```json
{
  "program": "Z_HELLO_WORLD",
  "user": "DEVELOPER",
  "client": "100",
  "language": "EN",
  "correlationId": "req-123",
  "parameters": {
    "input": "value"
  }
}
```

### Run Program Response

```json
{
  "success": true,
  "message": "Program executed",
  "statusCode": 200,
  "program": "Z_HELLO_WORLD",
  "correlationId": "req-123",
  "timestamp": "2026-02-15T10:00:00.0000000Z",
  "data": {
    "result": "..."
  }
}
```

## Example

See [examples/basic_usage.d](examples/basic_usage.d).
