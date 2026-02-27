# Task Center Service

This service provides an Task Center-style runtime with a unified REST interface for task federation and task processing.

## Features

- Federate tasks from and non-providers via a single REST contract.
- Cache federated tasks on disk (`TC_DATA_DIR` + `TC_CACHE_FILE`) for resilience and fast access.
- End-user task processing APIs for:
  - task inbox retrieval
  - search, sort, and filter
  - task detail inspection
  - task actions (claim, release, approve, reject, complete, reopen)
  - navigation hints to native task applications
- Optional bearer-token API protection via `TC_AUTH_TOKEN`.

## Build

```bash
dub build --root=./task-center
```

## Run

```bash
TC_AUTH_TOKEN=local-token dub run --root=./task-center
```

Defaults:

- Host: `0.0.0.0`
- Port: `8096`
- Base path: `/api/task-center`
- Cache dir: `/tmp/uim-task-center-data`

## API

### Ops

- `GET /api/task-center/health`
- `GET /api/task-center/ready`

### Provider management

- `GET /api/task-center/v1/providers`
- `POST /api/task-center/v1/providers`

Register provider payload:

```json
{
  "provider_id": "s4-approvals",
  "name": "S/4HANA Approvals",
  "provider_type": "sap",
  "endpoint": "https://example.sap/s4/tasks",
  "active": true
}
```

### Task federation (unified REST interface)

- `POST /api/task-center/v1/tenants/{tenantId}/providers/{providerId}/tasks`

Federation payload:

```json
{
  "tasks": [
    {
      "task_id": "4711",
      "provider_task_id": "WF-9001",
      "title": "Approve Purchase Order",
      "description": "PO 5000001234 requires approval",
      "assignee": "john.doe",
      "status": "open",
      "priority": "high",
      "due_at": "2026-03-15T09:00:00Z",
      "native_app_url": "https://example.sap/fiori#WorkflowTask-display",
      "native_app_name": "S/4HANA Workflow",
      "tags": ["po", "approval"],
      "attributes": {
        "purchase_order": "5000001234",
        "amount": 12500
      }
    }
  ]
}
```

### Task processing

List task inbox with search/sort/filter:

- `GET /api/task-center/v1/tenants/{tenantId}/tasks`

Supported query params:

- `assignee`
- `status` (`open|in_progress|completed|canceled|ready`)
- `provider_id`
- `priority` (`low|medium|high|critical`)
- `search` (substring match in title/description)
- `sort_by` (`updated_at|created_at|due_at|priority|title|status`)
- `sort_order` (`asc|desc`)
- `limit`
- `offset`

Task detail:

- `GET /api/task-center/v1/tenants/{tenantId}/tasks/{taskId}`

Perform task action:

- `POST /api/task-center/v1/tenants/{tenantId}/tasks/{taskId}/actions`

Action payload:

```json
{
  "action": "approve",
  "performed_by": "john.doe",
  "comment": "Looks good"
}
```

Navigate to native task app:

- `GET /api/task-center/v1/tenants/{tenantId}/tasks/{taskId}/navigate`

## Podman

Build image:

```bash
podman build -t uim-sap-task-center:latest ./task-center
```

Run container:

```bash
podman run --rm -p 8096:8096 \
  -e TC_AUTH_TOKEN=local-token \
  -e TC_DATA_DIR=/var/lib/uim-task-center \
  -v task-center-cache:/var/lib/uim-task-center \
  uim-sap-task-center:latest
```

## Kubernetes

Apply manifests:

```bash
kubectl apply -f ./task-center/k8s/configmap.yaml
kubectl apply -f ./task-center/k8s/deployment.yaml
kubectl apply -f ./task-center/k8s/service.yaml
```

Optional auth secret:

```bash
kubectl create secret generic uim-sap-task-center-secret \
  --from-literal=authToken=local-token
```
