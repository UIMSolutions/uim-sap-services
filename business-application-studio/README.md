# Business Application Studio Service

This module provides an SAP Business Application Studio-like backend service using **D**, **Vibe.D**, and **uim-framework**.

## Goals

- Easily develop and extend SAP solutions through scenario-based workspaces.
- Support key intelligent enterprise scenarios: **SAP Fiori**, **SAP S/4HANA extension**, and **Workflow**.
- Boost developer productivity via wizard runs, template catalogs, terminal access, local test/debug, and quick deployment endpoints.
- Offer browser-first, multi-cloud style availability metadata for anywhere access.

## Features

- Scenario and template catalog endpoints.
- Workspace lifecycle endpoints (create/list).
- Wizard execution endpoints for project generation from templates.
- Terminal session endpoints (CLI access simulation).
- Local test/debug run endpoint.
- Quick deployment queue endpoints.
- Platform availability endpoint (regions + hyperscalers).

## Build

```bash
dub build --root="./Business Application Studio"
```

## Run

```bash
BAS_AUTH_TOKEN=local-token dub run --root="./Business Application Studio"
```

Defaults:

- Host: `0.0.0.0`
- Port: `8088`
- Base path: `/api/business-application-studio`

## API Overview

### Ops

- `GET /api/business-application-studio/health`
- `GET /api/business-application-studio/ready`

### Scenarios and Templates

- `GET /api/business-application-studio/v1/tenants/{tenantId}/scenarios`
- `GET /api/business-application-studio/v1/tenants/{tenantId}/templates`

### Workspaces

- `GET /api/business-application-studio/v1/tenants/{tenantId}/workspaces`
- `POST /api/business-application-studio/v1/tenants/{tenantId}/workspaces`

### Productivity Tools

- `GET /api/business-application-studio/v1/tenants/{tenantId}/workspaces/{workspaceId}/wizard-runs`
- `POST /api/business-application-studio/v1/tenants/{tenantId}/workspaces/{workspaceId}/wizard-runs`
- `GET /api/business-application-studio/v1/tenants/{tenantId}/workspaces/{workspaceId}/terminal-sessions`
- `POST /api/business-application-studio/v1/tenants/{tenantId}/workspaces/{workspaceId}/terminal-sessions`
- `POST /api/business-application-studio/v1/tenants/{tenantId}/workspaces/{workspaceId}/tests/local-run`
- `GET /api/business-application-studio/v1/tenants/{tenantId}/workspaces/{workspaceId}/deployments`
- `POST /api/business-application-studio/v1/tenants/{tenantId}/workspaces/{workspaceId}/deployments`

### Platform Availability

- `GET /api/business-application-studio/v1/platform/availability`

## Example Payloads

Create workspace:

```json
{
  "name": "fiori-app-devspace",
  "scenario_id": "fiori",
  "region": "eu10",
  "terminal_enabled": true,
  "debug_enabled": true
}
```

Run wizard:

```json
{
  "template_id": "tpl-fiori-elements",
  "input": {
    "app_name": "sales-dashboard"
  }
}
```

Queue quick deployment:

```json
{
  "target": "sap-btp-cloud-foundry",
  "mode": "quick-deploy"
}
```

## Podman

```bash
podman build -t uim-sap-bas:latest "./Business Application Studio"
podman run --rm -p 8088:8088 \
  -e BAS_AUTH_TOKEN=local-token \
  uim-sap-bas:latest
```

## Kubernetes

```bash
kubectl apply -f "./Business Application Studio/k8s/configmap.yaml"
kubectl apply -f "./Business Application Studio/k8s/deployment.yaml"
kubectl apply -f "./Business Application Studio/k8s/service.yaml"
```

Optional auth secret:

```bash
kubectl create secret generic uim-sap-bas-secret \
  --from-literal=authToken=local-token
```
