# UIM SAP Analytics Cloud Service

Analytics and planning service built with Dlang, `vibe.d`, and `uim-framework`, inspired by SAP Analytics Cloud. Combines analytics, planning, and smart capabilities in an open cloud solution designed for Kubernetes and Podman deployment.

## Features

### User Experience
- **Stories**: Create presentation-style documents with charts, visualizations, text, and images. Support for canvas, responsive, and optimized layouts.
- **Dashboards**: Design interactive dashboards with real-time widgets, KPIs, and global filters. Turn stories into boardroom agendas.

### Capabilities
- **Interactive Dashboards**: Query data directly through dashboard widgets with grid, freeform, or responsive layouts.
- **Ad-Hoc Analysis**: Pivot-table style analysis with rows, columns, measures, and filters against data models.
- **Planning**: Create budget, forecast, and what-if plans linked to data models with approval workflows.

### Platforms and Data Connectivity
- **Connections**: Live, import, or blend connections to SAP HANA, SAP BW, SAP S/4HANA, SAP Datasphere, OData, CSV, and databases.
- **Datasets**: Import data from any source or connect live. Track import schedules and column/row metadata.
- **Data Models**: Define dimensions, measures, hierarchies, and variables for analysis and planning.
- **Embedding**: Embed stories and dashboards into third-party interfaces via embed tokens.

### Smart Capabilities
- **What-If Scenarios**: Simulate scenarios with adjustments against existing plans. View outcomes and confidence levels.
- **Predictions / AutoML**: Create time series, classification, regression, and clustering predictions. Automated algorithm selection with accuracy metrics (MAPE, RMSE, R²).
- **Forecasting**: Predict future values based on configurable horizon periods and confidence levels.

### Administration
- **Tenant Overview**: Monitor stories, dashboards, datasets, models, plans, predictions, connections, and user counts per tenant.
- **User Management**: Create, update, and manage users with roles (admin, bi_admin, planner, viewer, creator).
- **Connectivity Monitoring**: Test connections and track connection status.

### Mobile App
- Mobile-optimized catalog of published stories and dashboards for iOS and Android access.

### SAP Datasphere Integration
- Optional integration endpoint for SAP Datasphere for seamless and scalable access to critical business data.

## Build and Run

```bash
cd analytics
dub build
./build/uim-sap-analytics-service
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `ANALYTICS_HOST` | `0.0.0.0` | Bind address |
| `ANALYTICS_PORT` | `8090` | Listen port |
| `ANALYTICS_BASE_PATH` | `/api/analytics` | API base path |
| `ANALYTICS_SERVICE_NAME` | `uim-analytics` | Service name |
| `ANALYTICS_SERVICE_VERSION` | `1.0.0` | Service version |
| `ANALYTICS_MAX_STORIES` | `1000` | Max stories per tenant |
| `ANALYTICS_MAX_DASHBOARDS` | `500` | Max dashboards per tenant |
| `ANALYTICS_MAX_DATASETS` | `200` | Max datasets per tenant |
| `ANALYTICS_MAX_MODELS` | `100` | Max models per tenant |
| `ANALYTICS_MAX_CONNECTIONS` | `50` | Max connections per tenant |
| `ANALYTICS_MAX_USERS` | `10000` | Max users per tenant |
| `ANALYTICS_PREDICTION_TIMEOUT` | `300` | Prediction timeout (seconds) |
| `ANALYTICS_DEFAULT_PLAN` | `standard` | Default plan tier |
| `ANALYTICS_AUTH_TOKEN` | *(empty)* | Management auth token |
| `ANALYTICS_DATASPHERE_ENDPOINT` | *(empty)* | SAP Datasphere endpoint |

## Podman

```bash
cd analytics
podman build -t uim-sap-analytics .
podman run -p 8090:8090 uim-sap-analytics
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.example.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## UML (PlantUML)

Documentation diagrams in `docs/uml`:

- `docs/uml/component-architecture.puml`
- `docs/uml/class-model.puml`
- `docs/uml/sequence-story-analysis-planning.puml`

```bash
make uml        # PNG
make uml-svg    # SVG
make uml-clean  # Clean generated images
```

## REST API

Base path: `/api/analytics`

### Platform

- `GET /health`
- `GET /ready`

### Stories (User Experience)

- `GET    /v1/tenants/{tenant_id}/stories`
- `POST   /v1/tenants/{tenant_id}/stories`
- `GET    /v1/tenants/{tenant_id}/stories/{story_id}`
- `PUT    /v1/tenants/{tenant_id}/stories/{story_id}`
- `DELETE /v1/tenants/{tenant_id}/stories/{story_id}`

### Dashboards (Interactive)

- `GET    /v1/tenants/{tenant_id}/dashboards`
- `POST   /v1/tenants/{tenant_id}/dashboards`
- `GET    /v1/tenants/{tenant_id}/dashboards/{dashboard_id}`
- `PUT    /v1/tenants/{tenant_id}/dashboards/{dashboard_id}`
- `DELETE /v1/tenants/{tenant_id}/dashboards/{dashboard_id}`

### Datasets (Data Connectivity)

- `GET    /v1/tenants/{tenant_id}/datasets`
- `POST   /v1/tenants/{tenant_id}/datasets`
- `GET    /v1/tenants/{tenant_id}/datasets/{dataset_id}`
- `DELETE /v1/tenants/{tenant_id}/datasets/{dataset_id}`

### Data Models

- `GET    /v1/tenants/{tenant_id}/models`
- `POST   /v1/tenants/{tenant_id}/models`
- `GET    /v1/tenants/{tenant_id}/models/{model_id}`
- `DELETE /v1/tenants/{tenant_id}/models/{model_id}`

### Connections

- `GET    /v1/tenants/{tenant_id}/connections`
- `POST   /v1/tenants/{tenant_id}/connections`
- `GET    /v1/tenants/{tenant_id}/connections/{connection_id}`
- `POST   /v1/tenants/{tenant_id}/connections/{connection_id}/test`
- `DELETE /v1/tenants/{tenant_id}/connections/{connection_id}`

### Plans (Planning)

- `GET    /v1/tenants/{tenant_id}/plans`
- `POST   /v1/tenants/{tenant_id}/plans`
- `GET    /v1/tenants/{tenant_id}/plans/{plan_id}`
- `PUT    /v1/tenants/{tenant_id}/plans/{plan_id}`
- `DELETE /v1/tenants/{tenant_id}/plans/{plan_id}`

### What-If Scenarios (Smart)

- `POST   /v1/tenants/{tenant_id}/scenarios/simulate`

### Predictions / AutoML (Smart)

- `GET    /v1/tenants/{tenant_id}/predictions`
- `POST   /v1/tenants/{tenant_id}/predictions`
- `GET    /v1/tenants/{tenant_id}/predictions/{prediction_id}`

### Ad-Hoc Analysis

- `POST   /v1/tenants/{tenant_id}/analysis/query`

### Users (Administration)

- `GET    /v1/tenants/{tenant_id}/users`
- `POST   /v1/tenants/{tenant_id}/users`
- `GET    /v1/tenants/{tenant_id}/users/{user_id}`
- `PUT    /v1/tenants/{tenant_id}/users/{user_id}`
- `DELETE /v1/tenants/{tenant_id}/users/{user_id}`

### Tenant Overview (Administration)

- `GET    /v1/tenants/{tenant_id}/overview`

### Mobile Access

- `GET    /v1/tenants/{tenant_id}/mobile`

### SAP Datasphere Integration

- `GET    /v1/tenants/{tenant_id}/datasphere`

### Embedding

- `GET    /v1/tenants/{tenant_id}/embed/{resource_type}/{resource_id}`

## Example Flow

```bash
# 1) Create a connection to SAP HANA
curl -X POST "http://localhost:8090/api/analytics/v1/tenants/acme/connections" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Production HANA",
    "connection_type": "live",
    "source_system": "sap_hana",
    "host": "hana.prod.internal",
    "port": 443,
    "ssl_enabled": true
  }'

# 2) Import a dataset
curl -X POST "http://localhost:8090/api/analytics/v1/tenants/acme/datasets" \
  -H "Content-Type: application/json" \
  -d '{"name": "Sales Q4 2025", "source_type": "import"}'

# 3) Create a data model with dimensions and measures
curl -X POST "http://localhost:8090/api/analytics/v1/tenants/acme/models" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sales Analysis Model",
    "model_type": "planning",
    "dimensions": {"region": {"type": "string"}, "product": {"type": "string"}, "date": {"type": "date"}},
    "measures": {"revenue": {"type": "currency", "aggregation": "sum"}, "quantity": {"type": "integer", "aggregation": "sum"}},
    "hierarchies": {"region": ["country", "state", "city"]}
  }'

# 4) Create an interactive dashboard
curl -X POST "http://localhost:8090/api/analytics/v1/tenants/acme/dashboards" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Sales Performance Dashboard",
    "layout": "grid",
    "widgets": [
      {"type": "chart", "chart_type": "bar", "title": "Revenue by Region"},
      {"type": "kpi", "title": "Total Revenue", "measure": "revenue"},
      {"type": "table", "title": "Top Products"}
    ]
  }'

# 5) Run ad-hoc analysis
curl -X POST "http://localhost:8090/api/analytics/v1/tenants/acme/analysis/query" \
  -H "Content-Type: application/json" \
  -d '{
    "model_id": "<model_id>",
    "rows": ["region"],
    "columns": ["date"],
    "measures": ["revenue", "quantity"],
    "filters": {"date": {"from": "2025-01-01", "to": "2025-12-31"}}
  }'

# 6) Create a budget plan and simulate what-if
curl -X POST "http://localhost:8090/api/analytics/v1/tenants/acme/plans" \
  -H "Content-Type: application/json" \
  -d '{"name": "Budget 2026", "plan_type": "budget", "model_id": "<model_id>"}'

curl -X POST "http://localhost:8090/api/analytics/v1/tenants/acme/scenarios/simulate" \
  -H "Content-Type: application/json" \
  -d '{
    "plan_id": "<plan_id>",
    "scenario_name": "10% Revenue Increase",
    "adjustments": {"revenue": {"change_percent": 10}}
  }'

# 7) Create a prediction
curl -X POST "http://localhost:8090/api/analytics/v1/tenants/acme/predictions" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Revenue Forecast 2026",
    "prediction_type": "time_series",
    "target_column": "revenue",
    "horizon_periods": 12,
    "algorithm": "auto"
  }'

# 8) Get mobile catalog
curl "http://localhost:8090/api/analytics/v1/tenants/acme/mobile"

# 9) Tenant overview
curl "http://localhost:8090/api/analytics/v1/tenants/acme/overview"
```
