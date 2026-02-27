# UIM Intelligent Situation Automation-like Service (ISA)

Intelligent Situation Automation is an extension of Situation Handling. This service processes situations and resolves them automatically with business rules to reduce repetitive manual work.

Built with **Dlang**, **vibe.d**, and **uim-framework**, deployable using **Podman** and **Kubernetes**.

## Solution Overview

### 1) Create Configurations
Create, edit, and delete automation configurations that map business rules to situation types.

### 2) Situation Dashboard
Track estimated time saved by automated resolutions and receive suggestions for new automations.

### 3) Analyze Situations
View situation counts by type and filter by a single situation type for:
- resolution flow distribution
- situation instance details
- sample data context

### 4) Explore Related Situations
Inspect top entity types and related templates, view entity-to-situation relationships, and list imported situation data context reports.

## Build and run locally

```bash
cd intelligent-situation-automation
dub build
./build/uim-sap-isa-service
```

Base URL: `http://localhost:8088/api/situation-automation`

## Podman

```bash
cd intelligent-situation-automation
chmod +x build/podman-run.sh
./build/podman-run.sh
```

Or manually:

```bash
podman build -t uim-sap-isa:local .
podman run --rm -p 8088:8088 -e ISA_HOST=0.0.0.0 -e ISA_PORT=8088 uim-sap-isa:local
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.example.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml
```

## Environment variables

- `ISA_HOST` (default: `0.0.0.0`)
- `ISA_PORT` (default: `8088`)
- `ISA_BASE_PATH` (default: `/api/situation-automation`)
- `ISA_SERVICE_NAME` (default: `uim-sap-isa`)
- `ISA_SERVICE_VERSION` (default: `1.0.0`)
- `ISA_DEFAULT_TENANT` (default: `default`)
- `ISA_AUTH_TOKEN` (optional bearer token)

## API Overview

- `GET /health`
- `GET /ready`
- `GET,POST /v1/tenants/{tenantId}/configurations`
- `GET,PUT,DELETE /v1/tenants/{tenantId}/configurations/{configId}`
- `GET,POST /v1/tenants/{tenantId}/situations`
- `GET /v1/tenants/{tenantId}/dashboard`
- `GET /v1/tenants/{tenantId}/situations/analysis?type={situationType}`
- `GET /v1/tenants/{tenantId}/situations/explore`
- `GET /v1/tenants/{tenantId}/reports/context`

## Example flow

### Create an automation configuration

```bash
curl -sS -X POST http://localhost:8088/api/situation-automation/v1/tenants/default/configurations \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Auto resolve blocked invoices under threshold",
    "description": "Resolve blocked invoices if amount below approval threshold",
    "situation_type": "blocked_invoice",
    "enabled": true,
    "avg_manual_minutes": 8,
    "auto_resolution_rate": 0.85,
    "business_rules": [
      { "field": "amount", "op": "lte", "expected": "15000" },
      { "field": "currency", "op": "equals", "expected": "EUR" }
    ]
  }'
```

### Create a situation instance

```bash
curl -sS -X POST http://localhost:8088/api/situation-automation/v1/tenants/default/situations \
  -H 'Content-Type: application/json' \
  -d '{
    "situation_type": "blocked_invoice",
    "template_id": "tmpl-invoice-blocked",
    "entity_type": "invoice",
    "entity_id": "INV-9001",
    "status": "auto_resolved",
    "resolution_flow": "rule_based_auto_resolution",
    "data_context": {
      "amount": 4200,
      "currency": "EUR"
    }
  }'
```

### Read dashboard and analysis

```bash
curl -sS http://localhost:8088/api/situation-automation/v1/tenants/default/dashboard
curl -sS "http://localhost:8088/api/situation-automation/v1/tenants/default/situations/analysis?type=blocked_invoice"
curl -sS http://localhost:8088/api/situation-automation/v1/tenants/default/situations/explore
```
