# UIM Audit Log-like Service

Security and compliance-focused audit logging service built with Dlang, `vibe.d`, and `uim-framework`, designed for SAP BTP-style audit use-cases.

## Features and Use-Cases

- **Audit Log Write API**: write compliance audit events from applications/services; supports OAuth2-style token protection.
- **Recommended Audit Event Types**: exposes standard recommended event types and marks whether written events follow recommendations.
- **Audit Log Retrieval API (default)**: retrieve and preview audit logs within retention window, optional CSV download payload.
- **Audit Log Viewer (default)**: subaccount/tenant log viewer endpoint with latest events and event mix summary.
- **Audit Log Retention (default + advanced)**:
  - default plan: 90-day retention
  - premium plan: configurable retention above 90 days and estimated volume-based cost metrics

## Build and run

```bash
cd "Audit Log"
dub build
./build/uim-sap-audit-log-service
```

Environment variables:

- `AUDITLOG_HOST` (default `0.0.0.0`)
- `AUDITLOG_PORT` (default `8090`)
- `AUDITLOG_BASE_PATH` (default `/api/auditlog`)
- `AUDITLOG_SERVICE_NAME` (default `uim-sap-audit-log`)
- `AUDITLOG_SERVICE_VERSION` (default `1.0.0`)
- `AUDITLOG_DEFAULT_RETENTION_DAYS` (default `90`)
- `AUDITLOG_DEFAULT_PLAN` (`default` or `premium`, default `default`)
- `AUDITLOG_PREMIUM_COST_PER_1000` (default `0.75`)
- `AUDITLOG_AUTH_TOKEN` (optional management token)
- `AUDITLOG_OAUTH_TOKEN` (optional OAuth token required for write API)

## Podman

```bash
cd "Audit Log"
chmod +x build/podman-run.sh
./build/podman-run.sh
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.example.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## UML (PlantUML)

Separate UML descriptions are available in `docs/uml`:

- `docs/uml/component-architecture.puml`
- `docs/uml/class-model.puml`
- `docs/uml/sequence-write-retrieve-retention.puml`

Render helpers:

```bash
make uml-check
make uml
make uml-svg
make uml-clean
```

## REST API

Base path: `/api/auditlog`

### Platform

- `GET /health`
- `GET /ready`

### Event Types and Write

- `GET /v1/tenants/{tenant_id}/event-types`
- `POST /v1/tenants/{tenant_id}/events`

### Retrieval and Viewer

- `GET /v1/tenants/{tenant_id}/events`
- `POST /v1/tenants/{tenant_id}/events/retrieve`
- `GET /v1/tenants/{tenant_id}/viewer/logs`

### Retention and Premium Usage

- `GET /v1/tenants/{tenant_id}/retention`
- `PUT /v1/tenants/{tenant_id}/retention`
- `GET /v1/tenants/{tenant_id}/usage/cost`

## Example flow

```bash
# 1) Write event (OAuth-protected if configured)
curl -X POST "http://localhost:8090/api/auditlog/v1/tenants/acme/events" \
  -H "Content-Type: application/json" \
  -d '{
    "event_type":"security_event",
    "severity":"critical",
    "category":"auth",
    "message":"Privileged role granted",
    "source_service":"identity-service",
    "actor":"admin-user",
    "details":{"target_user":"u42"}
  }'

# 2) Retrieve and preview logs within retention
curl -X POST "http://localhost:8090/api/auditlog/v1/tenants/acme/events/retrieve" \
  -H "Content-Type: application/json" \
  -d '{"within_days":30,"event_type":"security_event","limit":200,"download":true}'

# 3) Configure premium retention
curl -X PUT "http://localhost:8090/api/auditlog/v1/tenants/acme/retention" \
  -H "Content-Type: application/json" \
  -d '{"plan":"premium","retention_days":365,"premium_cost_per_1000_events":0.95}'

# 4) Open viewer and usage
curl "http://localhost:8090/api/auditlog/v1/tenants/acme/viewer/logs"
curl "http://localhost:8090/api/auditlog/v1/tenants/acme/usage/cost"
```
