# UIM Identity Provisioning Service

A **SAP Cloud Identity Services – Identity Provisioning**-compatible service
built with **D**, **vibe.d**, and the **UIM Framework**.  It automates the
provisioning of users and groups between source and target systems with
transformation rules, full/delta read modes, job logging, and notification
subscriptions.

## Features

| Capability                     | Description                                                                      |
| ------------------------------ | -------------------------------------------------------------------------------- |
| **System registry**      | Register source, target, and proxy systems (SAP IAS, SAP SF, SCIM, LDAP, custom) |
| **User provisioning**    | CRUD for user entities with status tracking                                      |
| **Group provisioning**   | CRUD for group entities with membership                                          |
| **Transformation rules** | Map, filter, skip, and default-value rules per system and entity type            |
| **Full read**            | Read all users/groups from a source system and provision to targets              |
| **Delta read**           | Read only entities modified since the last sync (delta token)                    |
| **Job execution**        | Create and run provisioning jobs with counters and status tracking               |
| **Job logging**          | Per-job log entries with info/warning/error levels and export                    |
| **Notifications**        | Subscribe to job lifecycle events (started/completed/failed/cancelled)           |
| **Multitenancy**         | Every operation is scoped to a `tenantId` path segment                         |
| **Dashboard**            | Aggregated metrics per tenant                                                    |

## Quick Start

### Local (DUB)

```bash
cd identity-provisioning
dub run
# → http://localhost:8095/api/ip/health
```

### Podman

```bash
cd identity-provisioning
./build/podman-run.sh
# → http://localhost:8095/api/ip/health
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.example.yaml   # change the token first!
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Environment Variables

| Variable                | Default        | Description                                                        |
| ----------------------- | -------------- | ------------------------------------------------------------------ |
| `IPV_HOST`            | `0.0.0.0`    | Listen address                                                     |
| `IPV_PORT`            | `8095`       | Listen port                                                        |
| `IPV_BASE_PATH`       | `/api/ip`    | URL prefix for all endpoints                                       |
| `IPV_SERVICE_NAME`    | `uim-sap-ip` | Reported in `/health`                                            |
| `IPV_SERVICE_VERSION` | `1.0.0`      | Reported in `/health`                                            |
| `IPV_AUTH_TOKEN`      | *(empty)*    | If set, every request must carry `Authorization: Bearer <token>` |

## API Reference

All business endpoints are prefixed with
`{basePath}/v1/tenants/{tenantId}/…`

### Platform

| Method  | Path        | Description     |
| ------- | ----------- | --------------- |
| `GET` | `/health` | Health check    |
| `GET` | `/ready`  | Readiness probe |

### Systems

| Method     | Path                                            | Description                                  |
| ---------- | ----------------------------------------------- | -------------------------------------------- |
| `POST`   | `/v1/tenants/{tenantId}/systems`              | Register a system                            |
| `GET`    | `/v1/tenants/{tenantId}/systems`              | List systems (`?type=source\|target\|proxy`) |
| `GET`    | `/v1/tenants/{tenantId}/systems/{systemName}` | Get system details                           |
| `PUT`    | `/v1/tenants/{tenantId}/systems/{systemName}` | Update system                                |
| `DELETE` | `/v1/tenants/{tenantId}/systems/{systemName}` | Delete system                                |

### Users

| Method     | Path                                      | Description |
| ---------- | ----------------------------------------- | ----------- |
| `POST`   | `/v1/tenants/{tenantId}/users`          | Create user |
| `GET`    | `/v1/tenants/{tenantId}/users`          | List users  |
| `GET`    | `/v1/tenants/{tenantId}/users/{userId}` | Get user    |
| `PUT`    | `/v1/tenants/{tenantId}/users/{userId}` | Update user |
| `DELETE` | `/v1/tenants/{tenantId}/users/{userId}` | Delete user |

### Groups

| Method     | Path                                        | Description  |
| ---------- | ------------------------------------------- | ------------ |
| `POST`   | `/v1/tenants/{tenantId}/groups`           | Create group |
| `GET`    | `/v1/tenants/{tenantId}/groups`           | List groups  |
| `GET`    | `/v1/tenants/{tenantId}/groups/{groupId}` | Get group    |
| `DELETE` | `/v1/tenants/{tenantId}/groups/{groupId}` | Delete group |

### Transformations

| Method     | Path                                            | Description                    |
| ---------- | ----------------------------------------------- | ------------------------------ |
| `POST`   | `/v1/tenants/{tenantId}/transformations`      | Create transformation rule     |
| `GET`    | `/v1/tenants/{tenantId}/transformations`      | List rules (`?system_id=…`) |
| `GET`    | `/v1/tenants/{tenantId}/transformations/{id}` | Get transformation             |
| `DELETE` | `/v1/tenants/{tenantId}/transformations/{id}` | Delete transformation          |

### Provisioning Jobs

| Method   | Path                                                | Description                   |
| -------- | --------------------------------------------------- | ----------------------------- |
| `POST` | `/v1/tenants/{tenantId}/jobs`                     | Run provisioning job          |
| `GET`  | `/v1/tenants/{tenantId}/jobs`                     | List jobs                     |
| `GET`  | `/v1/tenants/{tenantId}/jobs/{jobId}`             | Get job details               |
| `POST` | `/v1/tenants/{tenantId}/jobs/{jobId}/cancel`      | Cancel a running job          |
| `GET`  | `/v1/tenants/{tenantId}/jobs/{jobId}/logs`        | List job logs (`?level=…`) |
| `GET`  | `/v1/tenants/{tenantId}/jobs/{jobId}/logs/export` | Export logs as JSON           |

### Notifications

| Method     | Path                                          | Description         |
| ---------- | --------------------------------------------- | ------------------- |
| `POST`   | `/v1/tenants/{tenantId}/notifications`      | Subscribe to events |
| `GET`    | `/v1/tenants/{tenantId}/notifications`      | List subscriptions  |
| `DELETE` | `/v1/tenants/{tenantId}/notifications/{id}` | Delete subscription |

### Dashboard

| Method  | Path                                 | Description                     |
| ------- | ------------------------------------ | ------------------------------- |
| `GET` | `/v1/tenants/{tenantId}/dashboard` | Aggregated provisioning metrics |

## Usage Examples

### Register a Source System

```bash
curl -X POST http://localhost:8095/api/ip/v1/tenants/myorg/systems \
  -H 'Content-Type: application/json' \
  -d '{
    "system_name": "sap-ias-prod",
    "system_type": "source",
    "connector_type": "sap-ias",
    "endpoint_url": "https://ias.example.com/scim",
    "auth_type": "oauth2",
    "description": "SAP IAS production tenant"
  }'
```

### Register a Target System

```bash
curl -X POST http://localhost:8095/api/ip/v1/tenants/myorg/systems \
  -H 'Content-Type: application/json' \
  -d '{
    "system_name": "azure-ad",
    "system_type": "target",
    "connector_type": "scim",
    "endpoint_url": "https://graph.microsoft.com/scim",
    "auth_type": "oauth2"
  }'
```

### Create a Transformation (Filter)

```bash
curl -X POST http://localhost:8095/api/ip/v1/tenants/myorg/transformations \
  -H 'Content-Type: application/json' \
  -d '{
    "system_id": "<source-system-id>",
    "entity_type": "user",
    "action": "filter",
    "source_attribute": "email",
    "condition": "contains @example.com",
    "priority": 1,
    "active": true
  }'
```

### Run a Full Read Provisioning Job

```bash
curl -X POST http://localhost:8095/api/ip/v1/tenants/myorg/jobs \
  -H 'Content-Type: application/json' \
  -d '{
    "job_name": "nightly-full-sync",
    "source_system_id": "<source-system-id>",
    "read_mode": "full"
  }'
```

### Run a Delta Read Job

```bash
curl -X POST http://localhost:8095/api/ip/v1/tenants/myorg/jobs \
  -H 'Content-Type: application/json' \
  -d '{
    "job_name": "hourly-delta-sync",
    "source_system_id": "<source-system-id>",
    "read_mode": "delta"
  }'
```

### View Job Logs (Errors Only)

```bash
curl "http://localhost:8095/api/ip/v1/tenants/myorg/jobs/<job-id>/logs?level=error"
```

### Export Job Logs

```bash
curl http://localhost:8095/api/ip/v1/tenants/myorg/jobs/<job-id>/logs/export > job-logs.json
```

### Subscribe to Job Events

```bash
curl -X POST http://localhost:8095/api/ip/v1/tenants/myorg/notifications \
  -H 'Content-Type: application/json' \
  -d '{
    "source_system_id": "<source-system-id>",
    "callback_url": "https://hooks.example.com/ip-events",
    "event_types": ["job.completed", "job.failed"]
  }'
```

### Dashboard

```bash
curl http://localhost:8095/api/ip/v1/tenants/myorg/dashboard
```

## Provisioning Flow

1. **Source system** reads users and groups (full or delta mode)
2. **Transformation rules** filter, map, skip, or default-fill attributes
3. **Target systems** receive the provisioned entities
4. **Job counters** track read/written/skipped/failed for users and groups
5. **Notification subscribers** are notified of job lifecycle events

## UML Description

PlantUML diagrams for this service are maintained in `docs/uml/`:

- `docs/uml/component-architecture.puml` - runtime components and external system context
- `docs/uml/class-model.puml` - key service/store/models structure
- `docs/uml/sequence-provisioning-job.puml` - end-to-end provisioning job lifecycle

Render diagrams locally:

```bash
make uml-check
make uml      # render PNG
make uml-svg  # render SVG
make uml-clean
```

Requirements: `plantuml` must be available in `PATH`.

## NAFv4 Description

This service can be read through a lightweight NAFv4 lens for architecture
traceability.

| NAFv4 Viewpoint                        | Identity Provisioning Mapping                                                                                                                              |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Capability View (NCV)**        | Identity lifecycle management, transformation governance, provisioning observability, and tenant-scoped operations                                         |
| **Operational View (NOV)**       | Actors (`Administrators`, `Scheduler/CI`) initiate system registration, transformation setup, and full/delta provisioning jobs                         |
| **Service-Oriented View (NSOV)** | Exposed REST services under `{basePath}/v1/tenants/{tenantId}/...` for systems, users, groups, transformations, jobs, logs, notifications, and dashboard |
| **System View (NSV)**            | Internal composition of `IPVServer` (API), `IPVService` (domain/provisioning engine), and `IPVStore` (in-memory persistence + locking)               |
| **Information View (NIV)**       | Core data entities:`IPVSystem`, `IPVUser`, `IPVGroup`, `IPVTransformation`, `IPVJob`, `IPVJobLog`, `IPVNotification`                         |
| **Standards View (NTV)**         | REST/HTTP + JSON payloads, SCIM-style identity concepts, and deployment alignment for local DUB, Podman, and Kubernetes                                    |

NAFv4-oriented concerns covered by this implementation:

- Multi-tenant boundary: all business operations are scoped by `tenantId`.
- Operational auditability: per-job logging and export endpoints.
- Integration governance: explicit source/target system registration and rule-based transformations.
- Execution resilience: full and delta read modes with job status and counters.

## Architecture

```
identity-provisioning/
├── source/
│   ├── app.d                                 # Entry point
│   └── uim/sap/identityprovisioning/
│       ├── package.d                         # Barrel imports
│       ├── config.d                          # IPVConfig
│       ├── server.d                          # IPVServer (vibe.d HTTP)
│       ├── service.d                         # IPVService (provisioning engine)
│       ├── store.d                           # IPVStore (in-memory, mutex)
│       ├── models/
│       │   ├── system.d                      # IPVSystem struct
│       │   ├── user.d                        # IPVUser struct
│       │   ├── group.d                       # IPVGroup struct
│       │   ├── transformation.d              # IPVTransformation struct
│       │   ├── job.d                         # IPVJob struct
│       │   ├── joblog.d                      # IPVJobLog struct
│       │   └── notification.d                # IPVNotification struct
│       ├── exceptions/                       # IPV*Exception hierarchy
│       └── helpers/
│           └── helper.d                      # evaluateCondition()
├── Dockerfile                                # Multi-stage Podman/Docker build
├── k8s/                                      # Kubernetes manifests
├── docs/uml/                                 # PlantUML diagrams
└── build/podman-run.sh                       # One-command Podman launch
```

## License

Apache-2.0 — Copyright © 2018-2026, Ozan Nurettin Süel
