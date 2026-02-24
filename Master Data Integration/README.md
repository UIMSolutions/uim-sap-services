# UIM  Master Data Integration Service (MDI)

Kubernetes-compatible SAP Master Data Integration style service built with D, vibe.d, and uim-framework.

## Features

- Master data replication between two or more clients
- Filter configuration to control replication scope (SAP Business Data Orchestration compatible pattern)
- Extensibility for aligned master data objects using additional fields and entities

## Build and Run

```bash
cd "Master Data Integration"
dub build
./build/uim-sap-mdi-service
```

Environment variables:

- MDI_HOST (default 0.0.0.0)
- MDI_PORT (default 8092)
- MDI_BASE_PATH (default /api/mdi)
- MDI_SERVICE_NAME (default uim-sap-mdi)
- MDI_SERVICE_VERSION (default 1.0.0)
- MDI_DEFAULT_OBJECT_TYPE (default business_partner)
- MDI_AUTH_TOKEN (optional bearer token)

## Podman Container

```bash
cd "Master Data Integration"
podman build -t uim-sap-mdi:local -f Dockerfile .
podman run --rm -p 8092:8092 --name uim-sap-mdi uim-sap-mdi:local
```

## REST API

Base path: /api/mdi

- GET /health
- GET /ready
- GET /v1/tenants/{tenant_id}/clients
- POST /v1/tenants/{tenant_id}/clients
- GET /v1/tenants/{tenant_id}/filters
- PUT /v1/tenants/{tenant_id}/filters/{filter_id}
- GET /v1/tenants/{tenant_id}/extensions
- PUT /v1/tenants/{tenant_id}/extensions/{extension_id}
- POST /v1/tenants/{tenant_id}/replication/run
- GET /v1/tenants/{tenant_id}/replication/jobs

### Example: register replication clients

```bash
curl -X POST "http://localhost:8092/api/mdi/v1/tenants/acme/clients" \
  -H "Content-Type: application/json" \
  -d '{"client_id":"erp-a","name":"ERP A","system_type":"sap"}'

curl -X POST "http://localhost:8092/api/mdi/v1/tenants/acme/clients" \
  -H "Content-Type: application/json" \
  -d '{"client_id":"erp-b","name":"ERP B","system_type":"sap"}'
```

### Example: configure filter

```bash
curl -X PUT "http://localhost:8092/api/mdi/v1/tenants/acme/filters/filter-bp-de" \
  -H "Content-Type: application/json" \
  -d '{
    "object_type": "business_partner",
    "active": true,
    "conditions": [
      {"field": "country", "op": "eq", "value": "DE"}
    ]
  }'
```

### Example: run replication

```bash
curl -X POST "http://localhost:8092/api/mdi/v1/tenants/acme/replication/run" \
  -H "Content-Type: application/json" \
  -d '{
    "source_client_id": "erp-a",
    "target_client_id": "erp-b",
    "object_type": "business_partner",
    "mode": "incremental",
    "filter_ids": ["filter-bp-de"]
  }'
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
