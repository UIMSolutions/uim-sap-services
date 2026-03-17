# Usage Data Management Service

`usage-data-management` is a D + vibe.d + UIM-framework microservice that emulates the SAP Usage Data Management Service for SAP BTP.

## Scope

This service provides REST APIs to gather, store, and report resource usage and distributed costs for cloud management and auditing scenarios.

Implemented reports:

- Monthly usage: Aggregated usage for a monthly interval per domain entity and metric.
- Subaccount usage: Aggregated usage for a daily interval per domain entity and metric.
- Monthly subaccount costs: Distributed monthly costs per subaccount and billable metric for CPEA-style models.

## Run locally

```bash
cd usage-data-management
dub run
```

Defaults:

- Host: `0.0.0.0`
- Port: `8109`
- Base path: `/api/usage-data-management`

## Podman

```bash
make podman-build
make podman-run
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## API overview

Base: `/api/usage-data-management/v1`

- `GET /discovery`
- `GET /tenants`
- `POST /tenants/{tenantId}/usage-events`
- `GET /tenants/{tenantId}/usage-events`
- `POST /tenants/{tenantId}/reports/monthly-usage`
- `POST /tenants/{tenantId}/reports/subaccount-usage`
- `POST /tenants/{tenantId}/reports/monthly-subaccount-costs`

## Example flow

1. Ingest usage events:

```bash
curl -X POST http://localhost:8109/api/usage-data-management/v1/tenants/tenant-a/usage-events \
  -H 'Content-Type: application/json' \
  -d '{
    "usage_event_id": "evt-1001",
    "account_id": "acc-001",
    "directory_id": "dir-emea",
    "subaccount_id": "sub-dev-01",
    "region": "eu10",
    "service_name": "hana-cloud",
    "plan_name": "standard",
    "metric": "memory_gb_hours",
    "quantity": 126.5,
    "unit": "GBh",
    "billable": true,
    "unit_price": 0.27,
    "currency": "EUR",
    "occurred_at": "2026-03-04T09:10:00Z"
  }'
```

1. Monthly usage report:

```bash
curl -X POST http://localhost:8109/api/usage-data-management/v1/tenants/tenant-a/reports/monthly-usage \
  -H 'Content-Type: application/json' \
  -d '{
    "month": "2026-03",
    "entity_type": "account",
    "metrics": ["memory_gb_hours"]
  }'
```

1. Daily subaccount usage report:

```bash
curl -X POST http://localhost:8109/api/usage-data-management/v1/tenants/tenant-a/reports/subaccount-usage \
  -H 'Content-Type: application/json' \
  -d '{
    "from_date": "2026-03-01",
    "to_date": "2026-03-31",
    "entity_type": "subaccount"
  }'
```

1. Monthly subaccount costs report:

```bash
curl -X POST http://localhost:8109/api/usage-data-management/v1/tenants/tenant-a/reports/monthly-subaccount-costs \
  -H 'Content-Type: application/json' \
  -d '{
    "month": "2026-03",
    "currency": "EUR"
  }'
```
