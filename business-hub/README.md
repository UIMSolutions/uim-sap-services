# UIM Business Hub-like Service (BUH)

Kubernetes-compatible Business Hub style service built with D, `vibe.d`, and `uim-framework`.

## Features

- API catalog management (`/catalog/apis`)
- Product packaging (`/catalog/products`)
- Subscription management (`/subscriptions`)
- Health and readiness endpoints for Kubernetes
- Optional Bearer auth for catalog operations
- In-memory storage for local development and platform prototyping

## Build & Run

```bash
cd buh
dub build
./build/uim-sap-buh-service
```

## Docker

```bash
cd buh
docker build -t uim-sap-buh:latest .

docker run --rm -p 8083:8083 \
  -e BUH_HOST=0.0.0.0 \
  -e BUH_PORT=8083 \
  uim-sap-buh:latest
```

Environment variables:

- `BUH_HOST` (default `0.0.0.0`)
- `BUH_PORT` (default `8083`)
- `BUH_BASE_PATH` (default `/api/hub`)
- `BUH_SERVICE_NAME` (default `uim-sap-buh`)
- `BUH_SERVICE_VERSION` (default `1.0.0`)
- `BUH_AUTH_TOKEN` (optional bearer token)

## API

Base path: `/api/hub`

- `GET /health`
- `GET /ready`
- `GET,POST /catalog/apis`
- `GET /catalog/apis/{id}`
- `GET,POST /catalog/products`
- `GET,POST /subscriptions`

### Example Flow

```bash
# create API
curl -X POST http://localhost:8083/api/hub/catalog/apis \
  -H 'Content-Type: application/json' \
  -d '{
    "name":"Sales Order API",
    "provider":"SAP",
    "version":"v1",
    "summary":"Create and query sales orders",
    "tags":["sales","orders"]
  }'

# list APIs
curl http://localhost:8083/api/hub/catalog/apis
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
