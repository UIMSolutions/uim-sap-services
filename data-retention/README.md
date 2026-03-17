# Data Retention Manager Service

`data-retention` is a D + vibe.d + UIM-framework microservice that emulates the SAP Data Retention Manager service for SAP BTP.

## Features

- Manage business purpose rules per application group and legal grounds.
- Define residence and retention periods and evaluate end-of-purpose/recommendation windows.
- Evaluate data subjects for block and delete eligibility after retention milestones.
- Manage retention and residence rules per legal ground for transactional entities.
- Create archive and destruction jobs with selection criteria over application and transaction ranges.
- Built-in multitenancy via tenant-scoped APIs and in-memory tenant isolation.

## Run locally

```bash
cd data-retention
dub run
```

Defaults:

- Host: `0.0.0.0`
- Port: `8110`
- Base path: `/api/data-retention`

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

Base: `/api/data-retention/v1`

- `GET /discovery`
- `GET|POST /tenants/{tenantId}/business-purposes`
- `GET|POST /tenants/{tenantId}/retention-rules`
- `GET /tenants/{tenantId}/data-subjects`
- `POST /tenants/{tenantId}/data-subjects/{dataSubjectId}`
- `POST /tenants/{tenantId}/data-subjects/{dataSubjectId}/evaluate`
- `POST /tenants/{tenantId}/archive-jobs`
- `POST /tenants/{tenantId}/destruction-jobs`
- `GET /tenants/{tenantId}/jobs`

## Example flow

1. Create business purpose/retention rule:

```bash
curl -X POST http://localhost:8110/api/data-retention/v1/tenants/acme/business-purposes \
  -H 'Content-Type: application/json' \
  -d '{
    "application_group": "sales-order-app",
    "purpose_name": "Order fulfillment and invoicing",
    "reference_date_field": "invoice_date",
    "legal_grounds": [
      {"legal_ground": "contract", "residence_days": 30, "retention_days": 365},
      {"legal_ground": "tax", "residence_days": 30, "retention_days": 3650}
    ]
  }'
```

1. Upsert data subject state:

```bash
curl -X POST http://localhost:8110/api/data-retention/v1/tenants/acme/data-subjects/ds-1001 \
  -H 'Content-Type: application/json' \
  -d '{
    "application_group": "sales-order-app",
    "legal_ground": "contract",
    "reference_date": "2025-01-15"
  }'
```

1. Evaluate end-of-purpose and retention completion:

```bash
curl -X POST http://localhost:8110/api/data-retention/v1/tenants/acme/data-subjects/ds-1001/evaluate
```

1. Create archive or destruction jobs:

```bash
curl -X POST http://localhost:8110/api/data-retention/v1/tenants/acme/archive-jobs \
  -H 'Content-Type: application/json' \
  -d '{
    "application_group": "sales-order-app",
    "entity_type": "transaction",
    "range_from": "2023-01-01",
    "range_to": "2023-03-31",
    "legal_ground": "contract",
    "include_data_subject_reference": true
  }'
```
