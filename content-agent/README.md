# UIM Content Agent Service

This module provides a Content Agent-like service built with Dlang, vibe.d and `uim-framework` conventions.

It covers the core use-cases:

- assemble content from providers into MTAR-ready exports,
- export assembled content to configured transport queues (CTS+ or Cloud Transport Management),
- view transport-relevant content details and activity history in the UI,
- support tenant-aware multitenancy by isolating all resources per tenant.

## Features

- Standardized home UI at `/api/content-agent/`
- Provider onboarding and tenant content catalog
- Dependency-aware content assembly between source/target subaccounts
- MTAR export metadata generation and download URL exposure
- Transport queue integration model:
  - `ctsplus`
  - `cloud-transport-management`
- Transport activity tracking for auditability

## Build and run

```bash
cd content-agent
dub build
./build/uim-sap-content-agent-service
```

Environment variables:

- `CAG_HOST` (default `0.0.0.0`)
- `CAG_PORT` (default `8096`)
- `CAG_BASE_PATH` (default `/api/content-agent`)
- `CAG_SERVICE_NAME` (default `uim-sap-content-agent`)
- `CAG_SERVICE_VERSION` (default `1.0.0`)
- `CAG_AUTH_TOKEN` (optional bearer token)
- `CAG_RUNTIME` (default `cloud-foundry`)

## Podman

```bash
cd content-agent
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

## API overview

Base path: `/api/content-agent`

- `GET /health`
- `GET /ready`
- `GET /` (home UI)

Tenant API:

- `GET|POST /v1/tenants/{tenant_id}/providers`
- `GET|POST /v1/tenants/{tenant_id}/content`
- `GET /v1/tenants/{tenant_id}/content/{content_id}`
- `GET|POST /v1/tenants/{tenant_id}/queues`
- `GET|POST /v1/tenants/{tenant_id}/assemblies`
- `GET /v1/tenants/{tenant_id}/assemblies/{assembly_id}`
- `GET /v1/tenants/{tenant_id}/assemblies/{assembly_id}/mtar`
- `POST /v1/tenants/{tenant_id}/assemblies/{assembly_id}/export`
- `GET /v1/tenants/{tenant_id}/activities`
