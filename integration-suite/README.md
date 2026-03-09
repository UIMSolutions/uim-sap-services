# UIM SAP Integration Suite Service (INT)

Enterprise-grade integration platform-as-a-service built with Dlang, `vibe.d`, and `uim-framework`, deployable with Podman and Kubernetes.

## Overview

This service provides an SAP Integration Suite-like iPaaS capability covering 11 integration domains:

| # | Capability | Resource Path | Description |
|---|-----------|--------------|-------------|
| 1 | **Cloud Integration** | `iflows`, `message-logs` | Design, deploy & monitor integration flows (iFlows) |
| 2 | **API Management** | `api-proxies`, `api-products`, `api-policies` | Discover, protect, govern & publish APIs |
| 3 | **Event Management** | `event-topics`, `event-subscriptions` | Publish & consume business events (event-driven architecture) |
| 4 | **Open Connectors** | `connectors` | Connect to non-SAP cloud applications |
| 5 | **Integration Advisor** | `mappings` | Design interfaces & mappings (crowdsourcing / ML) |
| 6 | **Trading Partner Mgmt** | `trading-partners`, `agreements` | Design & operate B2B scenarios |
| 7 | **OData Provisioning** | `odata-services` | Access business data in SAP Business Suite |
| 8 | **Integration Assessment** | `assessments` | INTA-M powered integration strategy guidance |
| 9 | **Migration Assessment** | `migrations` | Estimate SAP PO migration effort |
| 10 | **Hybrid Integration** | `hybrid-runtimes` | Manage private-landscape runtimes |
| 11 | **Data Space Integration** | `data-assets` | Offer, consume & maintain data space assets |
| — | **Content Packs** | `content-packs` | Pre-built best-practice integration packs |

## Build and run

```bash
cd integration-suite
dub build
./build/uim-sap-is-service
```

### Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `INT_HOST` | `0.0.0.0` | Bind address |
| `INT_PORT` | `8100` | Listen port |
| `INT_BASE_PATH` | `/api/is` | URL prefix |
| `INT_SERVICE_NAME` | `uim-sap-is` | Service identifier |
| `INT_SERVICE_VERSION` | `1.0.0` | Reported version |
| `INT_AUTH_TOKEN` | *(empty)* | Optional Bearer token |

## Podman

```bash
cd integration-suite
chmod +x build/podman-run.sh
./build/podman-run.sh
```

Or directly:

```bash
podman build -t uim-sap-is:local .
podman run --rm -p 8100:8100 uim-sap-is:local
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.example.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## REST API

Base path: `/api/is`

### Platform

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Health check |
| `GET` | `/ready` | Readiness probe |

All business routes follow the pattern `/v1/tenants/{tenant_id}/...`

### Cloud Integration

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `.../iflows` | Create integration flow |
| `GET` | `.../iflows` | List integration flows |
| `GET` | `.../iflows/{id}` | Get integration flow |
| `POST` | `.../iflows/{id}/deploy` | Deploy integration flow |
| `DELETE` | `.../iflows/{id}` | Delete integration flow |
| `POST` | `.../message-logs` | Create message log entry |
| `GET` | `.../message-logs` | List message logs |

### API Management

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `.../api-proxies` | Create API proxy |
| `GET` | `.../api-proxies` | List API proxies |
| `GET` | `.../api-proxies/{id}` | Get API proxy |
| `DELETE` | `.../api-proxies/{id}` | Delete API proxy |
| `POST` | `.../api-products` | Create API product |
| `GET` | `.../api-products` | List API products |
| `GET` | `.../api-products/{id}` | Get API product |
| `DELETE` | `.../api-products/{id}` | Delete API product |
| `POST` | `.../api-policies` | Create API policy |
| `GET` | `.../api-policies` | List API policies |
| `DELETE` | `.../api-policies/{id}` | Delete API policy |

### Event Management

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `.../event-topics` | Create event topic |
| `GET` | `.../event-topics` | List event topics |
| `POST` | `.../event-topics/{name}/publish` | Publish event |
| `DELETE` | `.../event-topics/{id}` | Delete event topic |
| `POST` | `.../event-subscriptions` | Create subscription |
| `GET` | `.../event-subscriptions` | List subscriptions |
| `DELETE` | `.../event-subscriptions/{id}` | Delete subscription |

### Open Connectors

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `.../connectors` | Create connector |
| `GET` | `.../connectors` | List connectors |
| `GET` | `.../connectors/{id}` | Get connector |
| `DELETE` | `.../connectors/{id}` | Delete connector |

### Integration Advisor

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `.../mappings` | Create mapping |
| `GET` | `.../mappings` | List mappings |
| `GET` | `.../mappings/{id}` | Get mapping |
| `DELETE` | `.../mappings/{id}` | Delete mapping |

### Trading Partner Management

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `.../trading-partners` | Create trading partner |
| `GET` | `.../trading-partners` | List trading partners |
| `GET` | `.../trading-partners/{id}` | Get trading partner |
| `DELETE` | `.../trading-partners/{id}` | Delete trading partner |
| `POST` | `.../agreements` | Create agreement |
| `GET` | `.../agreements` | List agreements |
| `GET` | `.../agreements/{id}` | Get agreement |
| `DELETE` | `.../agreements/{id}` | Delete agreement |

### OData Provisioning

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `.../odata-services` | Register OData service |
| `GET` | `.../odata-services` | List OData services |
| `GET` | `.../odata-services/{id}` | Get OData service |
| `DELETE` | `.../odata-services/{id}` | Delete OData service |

### Integration Assessment (INTA-M)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `.../assessments` | Create assessment |
| `GET` | `.../assessments` | List assessments |
| `GET` | `.../assessments/{id}` | Get assessment |
| `DELETE` | `.../assessments/{id}` | Delete assessment |

### Migration Assessment

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `.../migrations` | Create migration scenario |
| `GET` | `.../migrations` | List migrations |
| `GET` | `.../migrations/{id}` | Get migration |
| `POST` | `.../migrations/{id}/complete` | Mark migration completed |
| `DELETE` | `.../migrations/{id}` | Delete migration |

### Hybrid Integration

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `.../hybrid-runtimes` | Register hybrid runtime |
| `GET` | `.../hybrid-runtimes` | List hybrid runtimes |
| `GET` | `.../hybrid-runtimes/{id}` | Get hybrid runtime |
| `POST` | `.../hybrid-runtimes/{id}/heartbeat` | Send heartbeat |
| `DELETE` | `.../hybrid-runtimes/{id}` | Delete hybrid runtime |

### Data Space Integration

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `.../data-assets` | Create data asset |
| `GET` | `.../data-assets` | List data assets |
| `GET` | `.../data-assets/{id}` | Get data asset |
| `DELETE` | `.../data-assets/{id}` | Delete data asset |

### Content Packs

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `.../content-packs` | Create content pack |
| `GET` | `.../content-packs` | List content packs |
| `GET` | `.../content-packs/{id}` | Get content pack |
| `POST` | `.../content-packs/{id}/install` | Install content pack |
| `DELETE` | `.../content-packs/{id}` | Delete content pack |

### Dashboard

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `.../dashboard` | Aggregated tenant metrics |

## End-to-end examples

### 1) Create an integration flow

```bash
curl -X POST "http://localhost:8100/api/is/v1/tenants/acme/iflows" \
  -H "Content-Type: application/json" \
  -d '{"name":"Order Replication","description":"Replicate orders from S/4HANA to CRM","sender":"S4HANA","receiver":"CRM"}'
```

### 2) Deploy the flow

```bash
curl -X POST "http://localhost:8100/api/is/v1/tenants/acme/iflows/<IFLOW_ID>/deploy"
```

### 3) Create an API proxy

```bash
curl -X POST "http://localhost:8100/api/is/v1/tenants/acme/api-proxies" \
  -H "Content-Type: application/json" \
  -d '{"name":"Sales Order API","base_path":"/sales/orders","target_url":"https://s4.example.com/sap/opu/odata/sap/API_SALES_ORDER_SRV","auth_scheme":"oauth2"}'
```

### 4) Publish a business event

```bash
curl -X POST "http://localhost:8100/api/is/v1/tenants/acme/event-topics" \
  -H "Content-Type: application/json" \
  -d '{"topic_name":"sales/order/created","description":"Sales order creation events"}'

curl -X POST "http://localhost:8100/api/is/v1/tenants/acme/event-topics/sales%2Forder%2Fcreated/publish" \
  -H "Content-Type: application/json" \
  -d '{"payload":{"order_id":"SO-1001","amount":4200}}'
```

### 5) Register a non-SAP connector

```bash
curl -X POST "http://localhost:8100/api/is/v1/tenants/acme/connectors" \
  -H "Content-Type: application/json" \
  -d '{"name":"Salesforce CRM","provider":"Salesforce","auth_scheme":"oauth2","base_url":"https://login.salesforce.com"}'
```

### 6) Create a migration assessment

```bash
curl -X POST "http://localhost:8100/api/is/v1/tenants/acme/migrations" \
  -H "Content-Type: application/json" \
  -d '{"name":"PO to CI Migration - Orders","source_system":"PO","source_version":"7.50","scenario_type":"iflow","complexity":"medium"}'
```

### 7) View dashboard

```bash
curl "http://localhost:8100/api/is/v1/tenants/acme/dashboard"
```

## License

Apache-2.0
