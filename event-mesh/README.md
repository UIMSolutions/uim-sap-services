# UIM SAP Event Mesh Service (EVM)

Business event messaging service built with Dlang, `vibe.d`, and `uim-framework`, deployable with Podman and Kubernetes.

## Overview

This service provides an SAP Event Mesh-like capability for decoupled, event-driven communication between SAP and non-SAP applications:

- **Publish Business Events**: send events from any source (SAP S/4HANA, third-party systems, custom apps) to named topics.
- **Consume Business Events**: pull messages from queues that are automatically populated via topic-to-queue subscriptions.
- **Seamless Decoupled Communication**: topics, queues, subscriptions, and webhooks enable extension and integration scenarios without tight coupling.

## Build and run

```bash
cd event-mesh
dub build
./build/uim-sap-em-service
```

Environment variables:

- `EVM_HOST` (default `0.0.0.0`)
- `EVM_PORT` (default `8092`)
- `EVM_BASE_PATH` (default `/api/em`)
- `EVM_SERVICE_NAME` (default `uim-sap-em`)
- `EVM_SERVICE_VERSION` (default `1.0.0`)
- `EVM_AUTH_TOKEN` (optional bearer token)

## Podman

```bash
cd event-mesh
chmod +x build/podman-run.sh
./build/podman-run.sh
```

Or direct run:

```bash
podman build -t uim-sap-em:local .
podman run --rm -p 8092:8092 uim-sap-em:local
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
- `docs/uml/sequence-publish-consume.puml`

Render helpers:

```bash
make uml-check
make uml
make uml-svg
make uml-clean
```

## REST API

Base path: `/api/em`

### Platform

- `GET /health`
- `GET /ready`

### Queues

- `POST /v1/tenants/{tenant_id}/queues` — Create queue
- `GET  /v1/tenants/{tenant_id}/queues` — List queues
- `GET  /v1/tenants/{tenant_id}/queues/{queue_name}` — Get queue details
- `DELETE /v1/tenants/{tenant_id}/queues/{queue_name}` — Delete queue
- `GET  /v1/tenants/{tenant_id}/queues/{queue_name}/messages` — List messages
- `POST /v1/tenants/{tenant_id}/queues/{queue_name}/consume` — Consume next message
- `POST /v1/tenants/{tenant_id}/queues/{queue_name}/ack/{message_id}` — Acknowledge message
- `GET  /v1/tenants/{tenant_id}/queues/{queue_name}/deadletters` — List dead letter entries

### Topics

- `POST /v1/tenants/{tenant_id}/topics` — Create topic
- `GET  /v1/tenants/{tenant_id}/topics` — List topics
- `POST /v1/tenants/{tenant_id}/topics/{topic_name}/publish` — Publish event

### Subscriptions

- `POST /v1/tenants/{tenant_id}/subscriptions` — Create subscription (topic → queue)
- `GET  /v1/tenants/{tenant_id}/subscriptions` — List subscriptions

### Webhooks

- `POST /v1/tenants/{tenant_id}/webhooks` — Register webhook
- `GET  /v1/tenants/{tenant_id}/webhooks` — List webhooks
- `DELETE /v1/tenants/{tenant_id}/webhooks/{webhook_id}` — Delete webhook

### Dashboard

- `GET /v1/tenants/{tenant_id}/dashboard` — Get dashboard metrics

## End-to-end use case

### 1) Create a queue

```bash
curl -X POST "http://localhost:8092/api/em/v1/tenants/acme/queues" \
  -H "Content-Type: application/json" \
  -d '{"queue_name":"order-events","max_depth":5000}'
```

### 2) Create a topic

```bash
curl -X POST "http://localhost:8092/api/em/v1/tenants/acme/topics" \
  -H "Content-Type: application/json" \
  -d '{"topic_name":"sales/order/created","description":"Fired when a sales order is created"}'
```

### 3) Subscribe the queue to the topic

```bash
curl -X POST "http://localhost:8092/api/em/v1/tenants/acme/subscriptions" \
  -H "Content-Type: application/json" \
  -d '{"topic_name":"sales/order/created","queue_name":"order-events"}'
```

### 4) Publish an event

```bash
curl -X POST "http://localhost:8092/api/em/v1/tenants/acme/topics/sales%2Forder%2Fcreated/publish" \
  -H "Content-Type: application/json" \
  -d '{"publisher":"s4hana","source":"SAP","payload":{"order_id":"SO-1001","amount":4200}}'
```

### 5) Consume the message

```bash
curl -X POST "http://localhost:8092/api/em/v1/tenants/acme/queues/order-events/consume"
```

### 6) Acknowledge the message

```bash
curl -X POST "http://localhost:8092/api/em/v1/tenants/acme/queues/order-events/ack/<MESSAGE_ID>"
```

### 7) Register a webhook for delivery

```bash
curl -X POST "http://localhost:8092/api/em/v1/tenants/acme/webhooks" \
  -H "Content-Type: application/json" \
  -d '{"queue_name":"order-events","callback_url":"https://my-app.example.com/hooks/orders"}'
```

### 8) View dashboard

```bash
curl "http://localhost:8092/api/em/v1/tenants/acme/dashboard"
```
