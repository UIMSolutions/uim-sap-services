# UIM Advanced Event Mesh-like Service (AEM)

Event streaming, event management, and monitoring platform built with Dlang, `vibe.d`, and `uim-framework`, deployable with Podman and Kubernetes.

## Overview

This service provides an Integration Suite advanced event mesh-like capability for event-driven architecture (EDA) on a single platform:

- **Event Streaming**: deploy broker services, create event meshes, register topics, publish/inspect events.
- **Event Management**: design/discover/share EDA components and subscriptions, visualize relationships via model endpoint and UML.
- **Event Monitoring & Insights**: dashboard metrics, configurable notification rules, and alert generation for potential issues.

## Build and run

```bash
cd "Advanced Event Mesh"
dub build
./build/uim-sap-aem-service
```

Environment variables:

- `AEM_HOST` (default `0.0.0.0`)
- `AEM_PORT` (default `8088`)
- `AEM_BASE_PATH` (default `/api/aem`)
- `AEM_SERVICE_NAME` (default `uim-sap-aem`)
- `AEM_SERVICE_VERSION` (default `1.0.0`)
- `AEM_DEFAULT_REGION` (default `eu10`)
- `AEM_AUTH_TOKEN` (optional bearer token)

## Podman

```bash
cd "Advanced Event Mesh"
chmod +x build/podman-run.sh
./build/podman-run.sh
```

Or direct run:

```bash
podman build -t uim-sap-aem:local .
podman run --rm -p 8088:8088 uim-sap-aem:local
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.example.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## UML (PlantUML)

Separate UML descriptions are available in `docs/uml`:

- `docs/uml/component-architecture.puml`
- `docs/uml/class-model.puml`
- `docs/uml/sequence-publish-monitor.puml`

Render helpers:

```bash
make uml-check
make uml
make uml-svg
make uml-clean
```

## REST API

Base path: `/api/aem`

### Platform

- `GET /health`
- `GET /ready`

### Event Streaming

- `GET /v1/tenants/{tenant_id}/broker-services`
- `POST /v1/tenants/{tenant_id}/broker-services`
- `POST /v1/tenants/{tenant_id}/broker-services/{broker_service_id}/event-meshes`
- `GET /v1/tenants/{tenant_id}/event-meshes`
- `POST /v1/tenants/{tenant_id}/event-meshes/{mesh_id}/topics`
- `POST /v1/tenants/{tenant_id}/event-meshes/{mesh_id}/publish`
- `GET /v1/tenants/{tenant_id}/event-meshes/{mesh_id}/topics/{topic}/events`

### Event Management

- `GET /v1/tenants/{tenant_id}/components`
- `POST /v1/tenants/{tenant_id}/components`
- `POST /v1/tenants/{tenant_id}/components/{component_id}/subscriptions`
- `GET /v1/tenants/{tenant_id}/eda/model`

### Event Monitoring and Insights

- `GET /v1/tenants/{tenant_id}/monitoring/dashboard`
- `GET /v1/tenants/{tenant_id}/monitoring/alerts`
- `GET /v1/tenants/{tenant_id}/monitoring/notifications`
- `PUT /v1/tenants/{tenant_id}/monitoring/notifications/{rule_id}`

## End-to-end use case

### 1) Create broker service

```bash
curl -X POST "http://localhost:8088/api/aem/v1/tenants/acme/broker-services" \
  -H "Content-Type: application/json" \
  -d '{"name":"acme-broker","plan":"enterprise","region":"eu10"}'
```

### 2) Create event mesh

```bash
curl -X POST "http://localhost:8088/api/aem/v1/tenants/acme/broker-services/<BROKER_ID>/event-meshes" \
  -H "Content-Type: application/json" \
  -d '{"name":"acme-core-mesh","topics":["sales/order/created"]}'
```

### 3) Register EDA component + subscription

```bash
curl -X POST "http://localhost:8088/api/aem/v1/tenants/acme/components" \
  -H "Content-Type: application/json" \
  -d '{"name":"billing-service","component_type":"consumer","owner":"finance-team"}'

curl -X POST "http://localhost:8088/api/aem/v1/tenants/acme/components/<COMPONENT_ID>/subscriptions" \
  -H "Content-Type: application/json" \
  -d '{"mesh_id":"<MESH_ID>","topic":"sales/order/created"}'
```

### 4) Configure notification rule + publish event

```bash
curl -X PUT "http://localhost:8088/api/aem/v1/tenants/acme/monitoring/notifications/queue-depth-default" \
  -H "Content-Type: application/json" \
  -d '{"metric":"queue_depth","threshold":10,"severity":"warning","enabled":true,"channel":"email"}'

curl -X POST "http://localhost:8088/api/aem/v1/tenants/acme/event-meshes/<MESH_ID>/publish" \
  -H "Content-Type: application/json" \
  -d '{"topic":"sales/order/created","publisher":"sales-api","payload":{"order_id":"SO-1001"}}'
```

### 5) View dashboard and alerts

```bash
curl "http://localhost:8088/api/aem/v1/tenants/acme/monitoring/dashboard"
curl "http://localhost:8088/api/aem/v1/tenants/acme/monitoring/alerts"
```
