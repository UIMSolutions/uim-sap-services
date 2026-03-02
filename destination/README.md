# UIM SAP Destination Service

A cloud-based **Destination** service built with **D (Dlang)**, **Vibe.D** and
the **UIM Framework**. It mirrors the capabilities of the SAP BTP Destination
service.

## Features

| Capability | Description |
|---|---|
| **Manage Destinations** | Create and configure destination objects with connection details for remote services |
| **Multiple Protocols** | HTTP, RFC, LDAP, Mail, and TCP for cloud-to-cloud and cloud-to-on-premises |
| **Multi-Environment** | Cloud Foundry, Kyma, ABAP, and Kubernetes environments |
| **Authentication** | NoAuthentication, BasicAuthentication, OAuth2ClientCredentials, OAuth2SAMLBearerAssertion, ClientCertificateAuthentication, PrincipalPropagation, SAMLAssertion |
| **Certificate Store** | Upload and manage TLS certificates for destination connections |
| **Destination Lookup** | Find and resolve destination configuration by name at runtime |
| **Custom Properties** | Attach scenario-specific key-value properties to any destination |
| **Proxy Configuration** | Configure proxy type (Internet, OnPremise, PrivateLink) per destination |
| **Multi-tenant** | Tenant-isolated data store for all entities |

## Quick Start

```bash
# Build
dub build

# Run locally
DST_PORT=8104 ./build/uim-sap-dst-service

# Podman
cd build && bash podman-run.sh

# Kubernetes
kubectl apply -f k8s/
```

## API

Base path: `/api/destination`

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/health` | Health check |
| `GET` | `/ready` | Readiness probe |
| `GET` | `/` | Interactive dashboard |
| **Destinations** | | |
| `GET` | `/v1/tenants/:tid/destinations` | List all destinations |
| `POST` | `/v1/tenants/:tid/destinations` | Create a destination |
| `GET` | `/v1/tenants/:tid/destinations/:name` | Get destination by name |
| `PUT` | `/v1/tenants/:tid/destinations/:name` | Update a destination |
| `DELETE` | `/v1/tenants/:tid/destinations/:name` | Delete a destination |
| **Lookup** | | |
| `GET` | `/v1/tenants/:tid/destinations/:name/lookup` | Resolve destination for runtime use |
| **Certificates** | | |
| `GET` | `/v1/tenants/:tid/certificates` | List certificates |
| `POST` | `/v1/tenants/:tid/certificates` | Upload a certificate |
| `GET` | `/v1/tenants/:tid/certificates/:name` | Get certificate details |
| `DELETE` | `/v1/tenants/:tid/certificates/:name` | Delete a certificate |

## Configuration

| Variable | Default | Description |
|---|---|---|
| `DST_HOST` | `0.0.0.0` | Bind address |
| `DST_PORT` | `8104` | Listen port |
| `DST_BASE_PATH` | `/api/destination` | API base path |
| `DST_SERVICE_NAME` | `uim-sap-dst` | Service name |
| `DST_SERVICE_VERSION` | `1.0.0` | Reported version |
| `DST_RUNTIME` | `cloud-foundry` | Runtime environment |
| `DST_AUTH_TOKEN` | *(empty)* | Bearer token for auth |

## License

Apache-2.0 — see [LICENSE](../LICENSE).
