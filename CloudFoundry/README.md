# UIM CloudFoundry Service (CLF)

Kubernetes-compatible CloudFoundry-style API service built with D, `vibe.d`, and `uim-framework`.

## Features

- CloudFoundry-like REST resources for:
  - Organizations (`/v2/organizations`)
  - Spaces (`/v2/spaces`)
  - Apps (`/v2/apps`)
  - Service offerings (`/v2/services`)
  - Service instances (`/v2/service_instances`)
- Health and readiness probes for Kubernetes
- Optional bearer token auth for API access
- In-memory resource store (good for local dev, demos, and platform prototypes)

## Build & Run

```bash
cd clf
dub build
./build/uim-sap-clf-service
```

Environment variables:

- `CLF_HOST` (default `0.0.0.0`)
- `CLF_PORT` (default `8082`)
- `CLF_BASE_PATH` (default `/api/cf`)
- `CLF_SERVICE_NAME` (default `uim-sap-clf`)
- `CLF_SERVICE_VERSION` (default `1.0.0`)
- `CLF_AUTH_TOKEN` (optional bearer token)

## API

Base path: `/api/cf`

- `GET /health`
- `GET /ready`
- `GET,POST /v2/organizations`
- `GET,POST /v2/spaces`
- `GET,POST /v2/apps`
- `GET /v2/apps/{guid}`
- `GET /v2/services`
- `GET,POST /v2/service_instances`

### Example Flow

```bash
# 1) create org
curl -X POST http://localhost:8082/api/cf/v2/organizations \
  -H 'Content-Type: application/json' \
  -d '{"name":"dev-org"}'

# 2) list service offerings
curl http://localhost:8082/api/cf/v2/services
```

## Kubernetes

Deploy manifests:

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
