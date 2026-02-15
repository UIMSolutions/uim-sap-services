# UIM SAP Cloud Logging Service (SCI)

Kubernetes-ready SAP Cloud Logging style service implemented with D, `uim-framework`, and `vibe.d`.

## Features

- HTTP ingestion endpoint for single log events
- Batch ingestion endpoint for high-throughput log forwarding
- Query endpoint with tenant/source/level/text filters
- Health, readiness, and metrics endpoints for Kubernetes probes
- In-memory bounded log store (ring-buffer style retention)
- Optional Bearer token auth for write/query endpoints

## Build & Run

```bash
cd sci
dub build
./build/uim-sap-sci-service
```

Environment variables:

- `SCI_HOST` (default: `0.0.0.0`)
- `SCI_PORT` (default: `8081`)
- `SCI_BASE_PATH` (default: `/sap/cloud/logging/v1`)
- `SCI_MAX_ENTRIES` (default: `10000`)
- `SCI_DEFAULT_QUERY_LIMIT` (default: `100`)
- `SCI_AUTH_TOKEN` (optional bearer token)

## API

Base path: `/sap/cloud/logging/v1`

- `GET /health`
- `GET /ready`
- `GET /metrics`
- `POST /logs`
- `POST /logs/batch`
- `POST /logs/query`

### Ingest example

```bash
curl -X POST http://localhost:8081/sap/cloud/logging/v1/logs \
  -H 'Content-Type: application/json' \
  -d '{
    "tenant": "ACME",
    "source": "orders-api",
    "level": "INFO",
    "message": "Order created",
    "attributes": {"orderId": "4711"}
  }'
```

### Query example

```bash
curl -X POST http://localhost:8081/sap/cloud/logging/v1/logs/query \
  -H 'Content-Type: application/json' \
  -d '{
    "tenant": "ACME",
    "level": "ERROR",
    "contains": "timeout",
    "limit": 50
  }'
```

## Kubernetes

Manifests are in `k8s/`:

- `configmap.yaml`
- `deployment.yaml`
- `service.yaml`

Deploy:

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
