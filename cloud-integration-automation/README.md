# UIM SAP Cloud Integration Automation Service

A Dlang/Vibe.D/UIM-Framework microservice that replicates and extends the functionality of
SAP Cloud Integration Automation Service (CIAS).

## Features

- **User & Task-Centric Guided Workflows** – Step-by-step workflow execution for integration scenarios.
- **Planning Capabilities** – Create and manage integration scenario plans per tenant.
- **Guided Workflow Engine** – Full lifecycle: planned → running → completed/failed.
- **Role-Based Task Assignment** – Tasks carry instructions and are assigned to dedicated roles/users.
- **Landscape-Aware Instructions** – Tasks adapt based on selected SAP systems and integration scenario.
- **Automated Technical Configuration** – Flag tasks for automation and trigger them against target systems.
- **Monitoring & Logging** – Full log trail per workflow and task with severity levels.
- **Parameter Management** – Define and reuse parameters across all tasks in a workflow.
- **Multi-Tenancy** – All resources are scoped to a tenant ID.

## API Base Path

```
/api/cloud-integration-automation/v1/tenants/{tenantId}/
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Service health |
| GET | `/ready` | Readiness probe |
| GET/POST | `/v1/tenants/:t/roles` | Manage roles |
| GET/POST | `/v1/tenants/:t/systems` | Manage landscape systems |
| GET/POST | `/v1/tenants/:t/scenarios` | Manage integration scenarios |
| GET/POST | `/v1/tenants/:t/workflows` | Plan/list integration workflows |
| GET | `/v1/tenants/:t/workflows/:id` | Get workflow detail |
| POST | `/v1/tenants/:t/workflows/:id/start` | Start a workflow |
| POST | `/v1/tenants/:t/workflows/:id/complete` | Complete a workflow |
| GET/POST | `/v1/tenants/:t/workflows/:id/tasks` | List/add tasks |
| GET | `/v1/tenants/:t/workflows/:id/tasks/:tid` | Get task detail |
| POST | `/v1/tenants/:t/workflows/:id/tasks/:tid/assign` | Assign task to user/role |
| POST | `/v1/tenants/:t/workflows/:id/tasks/:tid/progress` | Update task status |
| POST | `/v1/tenants/:t/workflows/:id/tasks/:tid/automate` | Trigger automated config |
| GET/POST | `/v1/tenants/:t/workflows/:id/parameters` | Manage workflow parameters |
| GET | `/v1/tenants/:t/workflows/:id/logs` | View monitoring logs |

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
| `CIA_HOST` | `0.0.0.0` | Bind address |
| `CIA_PORT` | `8098` | HTTP port |
| `CIA_BASE_PATH` | `/api/cloud-integration-automation` | API base path |
| `CIA_SERVICE_NAME` | `uim-sap-cloud-integration-automation` | Service name |
| `CIA_SERVICE_VERSION` | `1.0.0` | Service version |
| `CIA_RUNTIME` | `cloud-foundry` | Runtime environment |
| `CIA_AUTH_TOKEN` | *(none)* | Optional bearer token for auth |
