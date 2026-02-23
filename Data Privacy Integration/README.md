# UIM Data Privacy Integration Service (DPI)

Kubernetes-compatible Data Privacy Integration style service built with D, vibe.d, and uim-framework.

## Features

- Retention management: define retention rules and trigger end-of-purpose deletions
- Information reporting: generate reports of stored personal data with export plus correction/deletion triggers
- Data anonymization: anonymize and pseudonymize unstructured free text, text-file content, and image metadata text
- Multitenancy support: all operations are tenant-aware through tenant-scoped endpoints

## Build and Run

```bash
cd "Data Privacy Integration"
dub build
./build/uim-sap-dpi-service
```

Environment variables:

- DPI_HOST (default 0.0.0.0)
- DPI_PORT (default 8093)
- DPI_BASE_PATH (default /api/dpi)
- DPI_SERVICE_NAME (default uim-sap-dpi)
- DPI_SERVICE_VERSION (default 1.0.0)
- DPI_DEFAULT_RETENTION_DAYS (default 365)
- DPI_AUTH_TOKEN (optional bearer token)

## Podman Container

```bash
cd "Data Privacy Integration"
podman build -t uim-sap-dpi:local -f Dockerfile .
podman run --rm -p 8093:8093 --name uim-sap-dpi uim-sap-dpi:local
```

## REST API

Base path: /api/dpi

- GET /health
- GET /ready
- POST /v1/privacy/anonymize
- POST /v1/tenants/{tenant_id}/records
- GET /v1/tenants/{tenant_id}/retention/rules
- PUT /v1/tenants/{tenant_id}/retention/rules/{rule_id}
- POST /v1/tenants/{tenant_id}/retention/trigger
- POST /v1/tenants/{tenant_id}/reporting/report
- POST /v1/tenants/{tenant_id}/reporting/export
- POST /v1/tenants/{tenant_id}/reporting/correct
- POST /v1/tenants/{tenant_id}/reporting/delete

### Example: set retention rule

```bash
curl -X PUT "http://localhost:8093/api/dpi/v1/tenants/acme/retention/rules/customer-retention" \
  -H "Content-Type: application/json" \
  -d '{
    "data_category": "customer-profile",
    "retention_days": 730,
    "active": true
  }'
```

### Example: generate and export report

```bash
curl -X POST "http://localhost:8093/api/dpi/v1/tenants/acme/reporting/report" \
  -H "Content-Type: application/json" \
  -d '{"subject_id": "subject-123"}'

curl -X POST "http://localhost:8093/api/dpi/v1/tenants/acme/reporting/export" \
  -H "Content-Type: application/json" \
  -d '{"subject_id": "subject-123"}'
```

### Example: anonymize text

```bash
curl -X POST "http://localhost:8093/api/dpi/v1/privacy/anonymize" \
  -H "Content-Type: application/json" \
  -d '{
    "mode": "anonymize",
    "type": "free_text",
    "content": "Contact me at alice@example.com or +49 123 456789"
  }'
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
