# SAP Cloud Integration Client for D

SAP Cloud Integration (CPI) client library for D language, built with uim-framework and vibe.d.

## Features

- Typed HTTP client for SAP CPI APIs
- Basic, OAuth2, and API key authentication
- Integration Runtime Artifact listing
- Message Processing Log listing
- iFlow endpoint trigger helper
- Retry logic and typed exception handling

## Installation

For dub.sdl:

```sdl
dependency "uim-sap-cpi" version="~>1.0.0"
```

For dub.json:

```json
{
  "dependencies": {
    "uim-sap-cpi": "~>1.0.0"
  }
}
```

## Quick Start

```d
import uim.sap.cpi;
import vibe.data.json : Json;

void main() {
    auto config = SAPCPIConfig.createBasic(
        "https://mytenant.it-cpi020.cfapps.eu10.hana.ondemand.com",
        "CPI_USER",
        "CPI_PASSWORD"
    );

    auto client = new SAPCPIClient(config);

    if (client.testConnection()) {
        auto artifacts = client.getIntegrationArtifacts(10, 0);
        auto mpl = client.getMessageProcessingLogs(10, 0, "COMPLETED");

        Json payload = Json.emptyObject;
        payload["orderId"] = Json("4500001234");

        auto trigger = client.triggerIntegrationFlow("/http/ORDERS_IFLOW", payload);
    }
}
```
