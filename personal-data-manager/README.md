# SAP Personal Data Manager — UIM Service

Personal data management service for SAP BTP, built with D, the UIM framework, and vibe.d.

Allows applications to identify data subjects and inform them about which of their personal data is stored and used.

## Features

- **Data Subject Identification** — register and search for data subjects (private, corporate, employee, business partner)
- **Personal Data Records** — track what personal data is stored, where, and under which legal basis
- **Data Subject Requests** — full GDPR workflow: access, rectification, erasure, restriction, portability, objection, information
- **Request Lifecycle** — draft → submitted → processing → completed/rejected/cancelled
- **Notifications** — notify data subjects about request status and send data reports
- **Data Usage Tracking** — record how and where personal data is processed
- **Data Reports** — generate comprehensive reports of all personal data for a subject
- **Multitenancy** — tenant-scoped data isolation with configurable limits

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/ready` | Readiness check |
| GET/POST | `/v1/tenants` | List / create tenants |
| GET | `/v1/tenants/{tid}` | Get tenant details |
| GET/POST | `/v1/tenants/{tid}/subjects` | List / register data subjects |
| GET | `/v1/tenants/{tid}/subjects/search?q=&type=` | Search subjects |
| GET/PUT/DELETE | `/v1/tenants/{tid}/subjects/{sid}` | Get / update / delete subject |
| GET/POST | `/v1/tenants/{tid}/subjects/{sid}/records` | List / add personal data records |
| DELETE | `/v1/tenants/{tid}/subjects/{sid}/records/{rid}` | Delete a record |
| GET | `/v1/tenants/{tid}/subjects/{sid}/report` | Generate data report |
| GET/POST | `/v1/tenants/{tid}/subjects/{sid}/requests` | List / create requests |
| GET | `/v1/tenants/{tid}/requests` | List all requests (optional `?status=`) |
| GET | `/v1/tenants/{tid}/requests/{rid}` | Get request details |
| POST | `/v1/tenants/{tid}/requests/{rid}/submit` | Submit draft request |
| POST | `/v1/tenants/{tid}/requests/{rid}/process` | Begin processing |
| POST | `/v1/tenants/{tid}/requests/{rid}/complete` | Complete request |
| POST | `/v1/tenants/{tid}/requests/{rid}/reject` | Reject request |
| POST | `/v1/tenants/{tid}/requests/{rid}/cancel` | Cancel request |
| GET | `/v1/tenants/{tid}/subjects/{sid}/notifications` | List notifications |
| POST | `/v1/tenants/{tid}/subjects/{sid}/notify` | Send notification |
| POST | `/v1/tenants/{tid}/subjects/{sid}/send-report` | Send data report notification |
| GET/POST | `/v1/tenants/{tid}/subjects/{sid}/usages` | List / add data usages |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PDM_HOST` | `0.0.0.0` | Bind host |
| `PDM_PORT` | `8092` | Bind port |
| `PDM_BASE_PATH` | `/api/pdm` | Base path prefix |
| `PDM_SERVICE_NAME` | `uim-pdm` | Service name |
| `PDM_AUTH_TOKEN` | *(none)* | Bearer token (enables auth when set) |
| `PDM_MAX_SUBJECTS_PER_TENANT` | `100000` | Max data subjects per tenant |
| `PDM_MAX_REQUESTS_PER_TENANT` | `10000` | Max requests per tenant |
| `PDM_MAX_RECORDS_PER_SUBJECT` | `500` | Max records per subject |
| `PDM_REQUEST_TIMEOUT_SECS` | `86400` | Request timeout (seconds) |
| `PDM_DEFAULT_TENANT_ID` | `default` | Default tenant ID |
| `PDM_MULTITENANCY` | `true` | Enable multitenancy |

## Build & Run

```bash
# Build
make build

# Run locally
make run

# Container
make container-build
make container-run
```

## Kubernetes

```bash
kubectl apply -f k8s/
```

## License

Apache-2.0
