# UIM BTP Library

A D language library for working with SAP Business Technology Platform (BTP) using the uim-framework and vibe.d.

## Features

- SAP BTP API HTTP client with vibe.d
- OAuth2 and Basic authentication support
- Cloud Foundry API operations
- ABAP environment and HANA operations
- Destinations and Connectivity services
- JSON serialization/deserialization for API responses
- Tenant, subdomain, and region configuration

## Building

```bash
cd sap-btp
dub build
```

## Usage

```d
import uim.sap.btp;

void main() {
  auto cfg = defaultConfig("MY_TENANT", "MY_SUBDOMAIN", "api.sap.hana.ondemand.com");
  cfg.username = "user@example.com";
  cfg.password = "password";
  
  auto client = new SAPBTPClient(cfg);
  auto apps = client.getApplications();
  writeln(apps);
}
```

## Configuration

Supports multiple authentication methods:
- Basic authentication (username/password)
- OAuth2 with client credentials
- Service instances with bound credentials

## SAP BTP Services

- **Cloud Foundry**: Manage apps, services, and buildpacks
- **ABAP Environment**: ABAP system operations
- **HANA Cloud**: Database operations
- **Destinations**: Configure and manage destinations
- **Connectivity**: Service connectivity management

## Notes

- Default base URL format: https://{subdomain}.{region}/
- Supports multiple SAP BTP regions and datacenters
- OAuth2 token refresh support

## License

Apache 2.0
