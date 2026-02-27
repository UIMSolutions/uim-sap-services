# Automation Pilot Service

This service provides an BTP Automation Pilot-like runtime for automating DevOps and operations scenarios in multi-tenant environments.

## Features

- Run predefined commands from BTP DevOps scenario catalogs.
- Create custom catalogs and custom commands (including chained/composed commands).
- Back up and restore custom content (on-demand and schedule-ready metadata).
- Store small sensitive values as secure reusable inputs.
- Schedule executions for one-time or recurring runs.
- React to events from services and platforms via event triggers.
- Generate content with AI from prompts.
- Operate in private/on-premise environments through queued private operations.

## Build

```bash
dub build --root="./Automation Pilot"
```

## Run

```bash
ATP_AUTH_TOKEN=local-token dub run --root="./Automation Pilot"
```

Defaults:

- Host: `0.0.0.0`
- Port: `8097`
- Base path: `/api/automation-pilot`
- AI provider: `mock-genai`

## API Overview

### Ops

- `GET /api/automation-pilot/health`
- `GET /api/automation-pilot/ready`

### Catalogs and Commands

- `GET /api/automation-pilot/v1/tenants/{tenantId}/catalogs`
- `POST /api/automation-pilot/v1/tenants/{tenantId}/catalogs`
- `GET /api/automation-pilot/v1/tenants/{tenantId}/catalogs/{catalogId}/commands`
- `POST /api/automation-pilot/v1/tenants/{tenantId}/catalogs/{catalogId}/commands`

### Executions (run predefined/custom commands)

- `GET /api/automation-pilot/v1/tenants/{tenantId}/executions`
- `POST /api/automation-pilot/v1/tenants/{tenantId}/executions`

### Backup and Restore

- `GET /api/automation-pilot/v1/tenants/{tenantId}/backups`
- `POST /api/automation-pilot/v1/tenants/{tenantId}/backups`
- `POST /api/automation-pilot/v1/tenants/{tenantId}/backups/restore`

### Secure Inputs

- `GET /api/automation-pilot/v1/tenants/{tenantId}/vault/inputs`
- `POST /api/automation-pilot/v1/tenants/{tenantId}/vault/inputs`

### Scheduling

- `GET /api/automation-pilot/v1/tenants/{tenantId}/schedules`
- `POST /api/automation-pilot/v1/tenants/{tenantId}/schedules`

### Event Reactions

- `GET /api/automation-pilot/v1/tenants/{tenantId}/event-triggers`
- `POST /api/automation-pilot/v1/tenants/{tenantId}/event-triggers`
- `POST /api/automation-pilot/v1/tenants/{tenantId}/events/fire`

### AI Content Generation

- `POST /api/automation-pilot/v1/tenants/{tenantId}/ai/generate`

### Private Environment Operations

- `POST /api/automation-pilot/v1/tenants/{tenantId}/private-env/operate`

## Example Payloads

Create custom command:

```json
{
  "command_id": "restart-and-verify",
  "name": "Restart and Verify",
  "description": "Restart app and check health endpoint",
  "command_type": "chain",
  "steps": ["cf restart my-app", "curl https://my-app/health"],
  "allow_private_environment": true,
  "defaults": {
    "timeout_seconds": 120
  }
}
```

Run command:

```json
{
  "command_id": "restart-and-verify",
  "trigger_type": "manual",
  "input": {
    "space": "prod"
  }
}
```

Generate AI content:

```json
{
  "content_type": "runbook",
  "prompt": "Create a safe rollback runbook for failed deployment"
}
```

## Podman

```bash
podman build -t uim-sap-atp:latest "./Automation Pilot"
podman run --rm -p 8097:8097 \
  -e ATP_AUTH_TOKEN=local-token \
  uim-sap-atp:latest
```

## Kubernetes

```bash
kubectl apply -f "./Automation Pilot/k8s/configmap.yaml"
kubectl apply -f "./Automation Pilot/k8s/deployment.yaml"
kubectl apply -f "./Automation Pilot/k8s/service.yaml"
```

Optional auth secret:

```bash
kubectl create secret generic uim-sap-atp-secret \
  --from-literal=authToken=local-token
```
