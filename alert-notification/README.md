# Alert Notification Service

`alert-notification` is a D + vibe.d + UIM-framework microservice that provides an SAP Alert Notification-like API.

## Features

- Common API for providers to publish alerts and consumers to subscribe.
- Real-time notification fan-out from alert events to matching subscriptions.
- Built-in platform event catalog for technical BTP-like events.
- Filtering events with conditions (event type, severity, source, tags).
- Multiple delivery actions (email, webhook, slack, teams, pagerduty, sap-event-mesh).
- Custom application events over REST API with matching against subscriptions.
- Multitenancy support with tenant-isolated subscriptions, alerts, and deliveries.

## Run locally

```bash
cd alert-notification
dub run
```

Defaults:

- Host: `0.0.0.0`
- Port: `8097`
- Base path: `/api/alert-notification`

## Podman

```bash
make podman-build
make podman-run
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## API overview

Base: `/api/alert-notification/v1`

- `GET /built-in-events`
- `GET /delivery-options`
- `GET /tenants/{tenantId}/overview`
- `POST /tenants/{tenantId}/providers/alerts`
- `GET /tenants/{tenantId}/alerts`
- `POST /tenants/{tenantId}/alerts/search`
- `GET|POST /tenants/{tenantId}/subscriptions`
- `GET|PUT|DELETE /tenants/{tenantId}/subscriptions/{subscriptionId}`
- `POST /tenants/{tenantId}/subscriptions/{subscriptionId}/test`
- `GET /tenants/{tenantId}/deliveries`
