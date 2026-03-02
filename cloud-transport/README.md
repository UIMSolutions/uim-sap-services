# UIM SAP Cloud Transport Management Service

A Dlang/Vibe.D/UIM-Framework microservice replicating SAP Cloud Transport Management.

## Features

- **Transport Nodes** – Model environments (Cloud Foundry, ABAP, Neo) as logical
  nodes with their runtime type and destination metadata.
- **Transport Routes** – Connect source and target nodes, supporting star topologies
  and complex multi-hop landscapes.
- **Transport Requests** – Group MTA archives and application-specific content into
  transport requests with full lifecycle tracking.
- **Import Queues** – Each target node has an import queue of pending transport
  requests; supports selective import, full import, and scheduled auto-import.
- **Content Attachments** – Attach MTA archives, iFlows, ABAP transports, or other
  typed content to transport requests.
- **Cross-Environment** – Source and target nodes can reside in different global
  accounts and different runtime environments.
- **Transport Actions** – Forward, import (single/all), reset, and schedule imports.
- **Transport Logs** – Full audit log per transport request for monitoring.
- **CI/CD Integration Ready** – POST endpoint to create transport requests
  programmatically from CI/CD pipelines.
- **Multi-Tenancy** – All resources scoped to a tenant ID.

## API Base Path

```
/api/cloud-transport
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Service health |
| GET | `/ready` | Readiness probe |
| GET | `/` | Dashboard UI |
| **Nodes** | | |
| GET/POST | `/v1/tenants/:t/nodes` | List/create transport nodes |
| GET | `/v1/tenants/:t/nodes/:id` | Get node detail |
| **Routes** | | |
| GET/POST | `/v1/tenants/:t/routes` | List/create transport routes |
| **Transport Requests** | | |
| GET/POST | `/v1/tenants/:t/requests` | List/create transport requests |
| GET | `/v1/tenants/:t/requests/:id` | Get request detail |
| POST | `/v1/tenants/:t/requests/:id/forward` | Forward request along route |
| **Import Queues** | | |
| GET | `/v1/tenants/:t/nodes/:id/queue` | List import queue for a node |
| POST | `/v1/tenants/:t/nodes/:id/queue/import` | Import selected or all requests |
| POST | `/v1/tenants/:t/nodes/:id/queue/schedule` | Set auto-import schedule |
| **Content** | | |
| GET/POST | `/v1/tenants/:t/requests/:id/content` | List/attach content items |
| **Logs** | | |
| GET | `/v1/tenants/:t/requests/:id/logs` | Transport request logs |

## Running with Podman

```bash
cd build && ./podman-run.sh
```

## Deploying to Kubernetes

```bash
kubectl apply -f k8s/
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CTM_HOST` | `0.0.0.0` | Bind address |
| `CTM_PORT` | `8100` | HTTP port |
| `CTM_BASE_PATH` | `/api/cloud-transport` | API base path |
| `CTM_SERVICE_NAME` | `uim-sap-ctm` | Service name |
| `CTM_SERVICE_VERSION` | `1.0.0` | Service version |
| `CTM_RUNTIME` | `cloud-foundry` | Runtime environment |
| `CTM_AUTH_TOKEN` | *(none)* | Optional bearer token for auth |
