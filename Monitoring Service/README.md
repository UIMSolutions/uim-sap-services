# UIM  Monitoring Service

Kubernetes-compatible monitoring service inspired by SAP BTP monitoring capabilities, implemented in D using `vibe.d` and `uim-framework`.

## Features

- Fetch application metrics
- Fetch metrics of a database system
- View history of metrics
- Register availability checks
- Set Alert Email Channel
- Set Alert Webhook Channel
- Configure JMX-based checks
- Perform JMX operations
- Register custom checks
- Override thresholds of a default check

## Build & Run

```bash
cd mon
dub build
./build/uim-sap-mon-service
```

Environment variables:

- `MON_HOST` (default `0.0.0.0`)
- `MON_PORT` (default `8090`)
- `MON_BASE_PATH` (default `/api/mon`)
- `MON_SERVICE_NAME` (default `uim-sap-mon`)
- `MON_SERVICE_VERSION` (default `1.0.0`)
- `MON_AUTH_TOKEN` (optional bearer token)

## REST API

Base path: `/api/mon`

- `GET /health`
- `GET /ready`
- `GET /v1/applications/{application_id}/metrics`
- `GET /v1/databases/{database_id}/metrics`
- `GET /v1/metrics/history/{target_type}/{target_id}` (`target_type`: `application` or `database`)
- `POST /v1/checks/availability`
- `PUT /v1/alerts/channels/email`
- `PUT /v1/alerts/channels/webhook`
- `GET /v1/alerts/channels`
- `POST /v1/checks/jmx`
- `POST /v1/jmx/operations`
- `POST /v1/checks/custom`
- `PUT /v1/checks/default/{check_name}/thresholds`
- `GET /v1/checks/default/{check_name}/thresholds`

## Example requests

Register availability check:

```bash
curl -X POST http://localhost:8090/api/mon/v1/checks/availability \
  -H 'Content-Type: application/json' \
  -d '{
    "target_type": "application",
    "target_id": "orders-api",
    "endpoint": "https://orders.internal/health",
    "interval_seconds": 30,
    "timeout_seconds": 5,
    "expected_status": 200,
    "enabled": true
  }'
```

Set alert email channel:

```bash
curl -X PUT http://localhost:8090/api/mon/v1/alerts/channels/email \
  -H 'Content-Type: application/json' \
  -d '{
    "enabled": true,
    "sender": "monitoring@uim.local",
    "subject_prefix": "[MON]",
    "recipients": ["ops@uim.local", "oncall@uim.local"]
  }'
```

Override thresholds for a default check:

```bash
curl -X PUT http://localhost:8090/api/mon/v1/checks/default/cpu-usage/thresholds \
  -H 'Content-Type: application/json' \
  -d '{
    "thresholds": {
      "warning": 75,
      "critical": 90,
      "unit": "%"
    }
  }'
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
