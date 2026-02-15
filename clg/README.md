# UIM Cloud Logging Service (CLG)

Kubernetes-ready Cloud Logging service implemented with D, `uim-framework`, and `vibe.d`.

## Features

- HTTP ingestion endpoint for single log events
- Batch ingestion endpoint for high-throughput log forwarding
- Query endpoint with tenant/source/level/text filters
- Health, readiness, and metrics endpoints for Kubernetes probes
- In-memory bounded log store (ring-buffer style retention)
- Optional Bearer token auth for write/query endpoints

## Build & Run

```bash
cd clg
dub build
./build/uim-sap-clg-service
```

Environment variables:

- `CLG_HOST` (default: `0.0.0.0`)
- `CLG_PORT` (default: `8081`)
- `CLG_BASE_PATH` (default: `/uim/cloud/logging/v1`)
- `CLG_MAX_ENTRIES` (default: `10000`)
- `CLG_DEFAULT_QUERY_LIMIT` (default: `100`)
- `CLG_AUTH_TOKEN` (optional bearer token)

## API

Base path: `/uim/cloud/logging/v1`

- `GET /health`
- `GET /ready`
- `GET /metrics`
- `POST /logs`
- `POST /logs/batch`
- `POST /logs/query`

### Ingest example

```bash
curl -X POST http://localhost:8081/uim/cloud/logging/v1/logs \
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
curl -X POST http://localhost:8081/uim/cloud/logging/v1/logs/query \
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
