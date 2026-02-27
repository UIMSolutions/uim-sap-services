# UIM Datasphere Service

Kubernetes-compatible Datasphere-like service built with D, vibe.d, and uim-framework.

## Capability Coverage

- Data modeling: graphical/SQL/data-flow metadata APIs, replication jobs, and external dataset enrichment entries (CSV, marketplace, third-party)
- Business modeling: semantic model APIs with dimensions/measures and built-in preview endpoint
- Data integration: SAP/non-connection registry and migration job API for trusted BW/SQL DW model onboarding
- Space management: secure spaces with storage allocation, priority, membership, and runtime update APIs
- Administration: tenant-level settings, connectivity preparation, maintenance controls, and monitoring metadata
- Data protection and privacy: functional/space access setup, row-level security policies, and audit read/change events
- Data governance: catalog assets, glossary terms, and KPI definitions for self-service reuse
- Consumption: connector discovery for Analytics Cloud, Microsoft Excel, and public OData-compatible entity endpoint

## Build and Run

```bash
cd "Datasphere"
dub build
./build/uim-sap-datasphere-service
```

Environment variables:

- DATASPHERE_HOST (default 0.0.0.0)
- DATASPHERE_PORT (default 8098)
- DATASPHERE_BASE_PATH (default /api/datasphere)
- DATASPHERE_SERVICE_NAME (default uim-sap-datasphere)
- DATASPHERE_SERVICE_VERSION (default 1.0.0)
- DATASPHERE_DEFAULT_SPACE_DISK_GB (default 50)
- DATASPHERE_DEFAULT_SPACE_MEMORY_GB (default 16)
- DATASPHERE_AUTH_TOKEN (optional bearer token)

## Podman

```bash
cd "Datasphere"
podman build -t uim-sap-datasphere:local -f Dockerfile .
podman run --rm -p 8098:8098 --name uim-sap-datasphere uim-sap-datasphere:local
```

## API Routes

Base path: /api/datasphere

- GET /health
- GET /ready
- GET|PUT /v1/admin/tenant
- POST|GET /v1/tenants/{tenant_id}/modeling/data-models
- POST /v1/tenants/{tenant_id}/modeling/external-datasets
- POST /v1/tenants/{tenant_id}/modeling/data-flows
- POST /v1/tenants/{tenant_id}/modeling/replications
- POST|GET /v1/tenants/{tenant_id}/business-modeling/models
- POST /v1/tenants/{tenant_id}/business-modeling/models/{model_id}/preview
- POST|GET /v1/tenants/{tenant_id}/integration/connections
- POST /v1/tenants/{tenant_id}/integration/migrations
- POST|GET /v1/tenants/{tenant_id}/spaces
- PUT /v1/tenants/{tenant_id}/spaces/{space_id}
- POST /v1/tenants/{tenant_id}/spaces/{space_id}/users
- PUT /v1/tenants/{tenant_id}/security/functional-access/{role}
- PUT /v1/tenants/{tenant_id}/security/space-access/{space_id}
- PUT /v1/tenants/{tenant_id}/security/row-policies/{policy_id}
- GET /v1/tenants/{tenant_id}/security/row-policies/
- POST|GET /v1/tenants/{tenant_id}/security/audit/
- POST|GET /v1/tenants/{tenant_id}/governance/catalog/assets
- POST|GET /v1/tenants/{tenant_id}/governance/glossary/terms
- POST|GET /v1/tenants/{tenant_id}/governance/kpis/definitions
- GET /v1/tenants/{tenant_id}/consumption/connectors
- GET /v1/tenants/{tenant_id}/consumption/odata/{entitySet}

## Quick Examples

Create a data model:

```bash
curl -X POST "http://localhost:8098/api/datasphere/v1/tenants/acme/modeling/data-models" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sales Fact",
    "model_type": "sql",
    "sql_definition": "select * from sales",
    "sources": ["S4HANA", "CSV"]
  }'
```

Create and configure a space:

```bash
curl -X POST "http://localhost:8098/api/datasphere/v1/tenants/acme/spaces" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "finance-space",
    "disk_gb": 200,
    "memory_gb": 64,
    "priority": 9,
    "users": ["alice", "bob"]
  }'
```

Publish a catalog asset:

```bash
curl -X POST "http://localhost:8098/api/datasphere/v1/tenants/acme/governance/catalog/assets" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Trusted Revenue Dataset",
    "asset_type": "dataset",
    "quality": "trusted"
  }'
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
