# UIM Responsibility Management Service

Responsibility Management style service for BTP scenarios, built with D, `vibe.d`, and `uim-framework`.

## Features

- Maintain responsibility rules (condition-based or external API mapping)
- Maintain teams, team owners, members, functions, and team types
- Determine responsible agents for contexts/documents and generate notifications
- Monitor agent-determination logs
- Download tenant/space customer data export as JSON
- Multitenancy support with tenant-aware data isolation

## Build and Run

```bash
cd "Responsibility Management"
dub build
./build/uim-sap-responsibility-management-service
```

## Smoke Test

Run automated checks for team/rule maintenance, agent determination, logs, and export:

```bash
cd "Responsibility Management"
bash scripts/smoke-test.sh
```

Optional variables:

- `BASE_URL` (default `http://localhost:8095/api/rms`)
- `TENANT_ID` (default `t1`)
- `SPACE_ID` (default `workflow`)
- `AUTH_TOKEN` (optional)
- `TEAM_NAME` (default `Smoke Invoice Team`)

## Podman

```bash
cd "Responsibility Management"
podman build -t uim-sap-rms:local -f Dockerfile .
podman run --rm \
  -p 8095:8095 \
  -e RMS_AUTH_TOKEN=secret123 \
  -v $(pwd)/build/rms-data:/var/lib/uim-rms:Z \
  uim-sap-rms:local
```

## Kubernetes

```bash
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Environment Variables

- `RMS_HOST` (default `0.0.0.0`)
- `RMS_PORT` (default `8095`)
- `RMS_BASE_PATH` (default `/api/rms`)
- `RMS_SERVICE_NAME` (default `uim-sap-rms`)
- `RMS_SERVICE_VERSION` (default `1.0.0`)
- `RMS_DATA_DIR` (default `/tmp/uim-rms-data`)
- `RMS_DEFAULT_TENANT` (default `provider`)
- `RMS_DEFAULT_SPACE` (default `dev`)
- `RMS_LOG_RETENTION` (default `500`)
- `RMS_AUTH_TOKEN` (optional bearer token for management APIs)

## API

Base path: `/api/rms`

Health:

- `GET /health`
- `GET /ready`

Master data:

- `GET /v1/team-categories`
- `GET /v1/team-types`
- `PUT /v1/team-types/{code}`
- `DELETE /v1/team-types/{code}`
- `GET /v1/functions`
- `PUT /v1/functions/{code}`
- `DELETE /v1/functions/{code}`

Team management:

- `GET /v1/teams`
- `POST /v1/teams`
- `GET /v1/teams/{teamId}`
- `PUT /v1/teams/{teamId}`
- `DELETE /v1/teams/{teamId}`
- `POST /v1/teams/{teamId}/copy`

Rules:

- `GET /v1/rules`
- `POST /v1/rules`
- `GET /v1/rules/{ruleId}`
- `PUT /v1/rules/{ruleId}`
- `DELETE /v1/rules/{ruleId}`

Runtime:

- `POST /v1/determine`
- `GET /v1/logs?limit=100`
- `GET /v1/export`

Required/optional headers:

- `X-Tenant-ID` (optional, defaults by config)
- `X-Space-ID` (optional, defaults by config)
- `Authorization: Bearer <token>` (required only when `RMS_AUTH_TOKEN` is configured)

## Example

Create team:

```bash
curl -X POST "http://localhost:8095/api/rms/v1/teams" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-ID: t1" \
  -H "X-Space-ID: workflow" \
  -H "Authorization: Bearer secret123" \
  -d '{
    "name": "Invoice Team",
    "type_code": "DEFAULT",
    "category_code": "FINANCE",
    "members": [
      {
        "user_id": "alice",
        "display_name": "Alice",
        "is_owner": true,
        "notifications_enabled": true,
        "functions": ["APPROVER"]
      }
    ]
  }'
```

Create rule:

```bash
curl -X POST "http://localhost:8095/api/rms/v1/rules" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-ID: t1" \
  -H "X-Space-ID: workflow" \
  -H "Authorization: Bearer secret123" \
  -d '{
    "name": "Invoice overdue approver",
    "context_type": "invoice",
    "object_type": "document",
    "mode": "condition",
    "condition_field": "status",
    "condition_equals": "OVERDUE",
    "team_id": "<TEAM_ID>",
    "function_code": "APPROVER",
    "priority": 200,
    "enabled": true
  }'
```

Determine agents:

```bash
curl -X POST "http://localhost:8095/api/rms/v1/determine" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-ID: t1" \
  -H "X-Space-ID: workflow" \
  -H "Authorization: Bearer secret123" \
  -d '{
    "context_type": "invoice",
    "object_type": "document",
    "document_id": "INV-100042",
    "payload": {
      "status": "OVERDUE"
    },
    "notify": true
  }'
```

Export customer data:

```bash
curl "http://localhost:8095/api/rms/v1/export" \
  -H "X-Tenant-ID: t1" \
  -H "X-Space-ID: workflow" \
  -H "Authorization: Bearer secret123"
```
