# S/4HANA Client for D

S/4HANA client library for D language, built with uim-framework and vibe.d.

## Features

- Typed S/4HANA HTTP/OData client
- Basic, OAuth2, and API key authentication
- OData helper methods for GET and POST
- Convenience method for Business Partner API
- Retry handling and typed exception hierarchy

## Installation

For `dub.sdl`:

```sdl
dependency "uim-sap-s4hana" version="~>1.0.0"
```

For `dub.json`:

```json
{
  "dependencies": {
    "uim-sap-s4hana": "~>1.0.0"
  }
}
```

## Quick Start

```d
import uim.sap.s4hana;
import vibe.data.json : Json;

void main() {
    auto config = SAPS4HANAConfig.createBasic(
        "https://my-s4hana.example.com",
        "SAPUSER",
        "SAPPASSWORD",
        "100"
    );

    auto client = new SAPS4HANAClient(config);

    if (client.testConnection()) {
        auto partners = client.getBusinessPartners(10, 0);

        Json payload = Json.emptyObject;
        payload["BusinessPartnerCategory"] = Json("2");
        payload["OrganizationBPName1"] = Json("Demo Customer");

        auto createResult = client.postOData(
            "API_BUSINESS_PARTNER",
            "A_BusinessPartner",
            payload
        );
    }
}
```
