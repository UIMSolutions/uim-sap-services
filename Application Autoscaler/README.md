# UIM  Application Autoscaler-like Service (AAS)

Cloud Foundry-oriented application autoscaling service built with Dlang, `vibe.d`, and `uim-framework`, deployable with Podman and Kubernetes.

## What this service provides

- **Scale applications on CF automatically** using policy-driven recommendations and apply actions.
- **Automatically increase or decrease instances** based on changing runtime metrics.
- **Resource-specific scaling** for CPU, memory, response time, and throughput.
- **Custom metric scaling** for domain-specific signals (for example queue lag, business events, latency percentiles).
- **Cost-aware decisions** through projected hourly compute cost and savings.

## Architecture

- HTTP API (`vibe.d`) exposing autoscaler operations.
- In-memory app registry and policy store (fast local prototyping).
- Policy evaluation engine that computes `scale_out`, `scale_in`, or `hold`.
- Cloud Foundry scale action endpoint (adapter placeholder, ready for CF CLI/CC API binding).
- Kubernetes manifests for service deployment and horizontal scaling.

## Build and run locally

```bash
cd "Application Autoscaler"
dub build
./build/uim-sap-aas-service
```

Default base URL: `http://localhost:8086/api/autoscaler`

## Podman

### Option 1: direct commands

```bash
cd "Application Autoscaler"
podman build -t uim-sap-aas:local .

podman run --rm -p 8086:8086 \
  -e AAS_HOST=0.0.0.0 \
  -e AAS_PORT=8086 \
  -e AAS_BASE_PATH=/api/autoscaler \
  -e AAS_CF_API=https://api.cf.example \
  uim-sap-aas:local
```

### Option 2: helper script

```bash
cd "Application Autoscaler"
chmod +x build/podman-run.sh
./build/podman-run.sh
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

- `AAS_HOST` (default `0.0.0.0`)
- `AAS_PORT` (default `8086`)
- `AAS_BASE_PATH` (default `/api/autoscaler`)
- `AAS_SERVICE_NAME` (default `uim-sap-aas`)
- `AAS_SERVICE_VERSION` (default `1.0.0`)
- `AAS_AUTH_TOKEN` (optional bearer token)
- `AAS_CF_API` (optional CF API endpoint)
- `AAS_CF_ORG` (optional default CF organization)
- `AAS_CF_SPACE` (optional default CF space)

## API overview

- `GET /health`
- `GET /ready`
- `GET,POST /apps`
- `GET /apps/{appId}`
- `GET,POST /apps/{appId}/policies`
- `POST /apps/{appId}/metrics/evaluate` (dry-run decision)
- `POST /apps/{appId}/metrics/evaluate/apply` (apply decision)
- `POST /cf/apps/{appId}/scale` (manual CF scale action)

## End-to-end use case

### 1) Register application

```bash
curl -sS -X POST http://localhost:8086/api/autoscaler/apps \
  -H 'Content-Type: application/json' \
  -d '{
    "name":"orders-api",
    "organization":"prod-org",
    "space":"payments",
    "current_instances":2,
    "min_instances":2,
    "max_instances":12,
    "instance_hourly_cost":0.09
  }'
```

### 2) Add CPU policy

```bash
curl -sS -X POST http://localhost:8086/api/autoscaler/apps/<APP_ID>/policies \
  -H 'Content-Type: application/json' \
  -d '{
    "metric_type":"cpu",
    "scale_out_threshold":75,
    "scale_in_threshold":35,
    "scale_out_step":2,
    "scale_in_step":1,
    "min_instances":2,
    "max_instances":12
  }'
```

### 3) Add custom metric policy

```bash
curl -sS -X POST http://localhost:8086/api/autoscaler/apps/<APP_ID>/policies \
  -H 'Content-Type: application/json' \
  -d '{
    "metric_type":"custom",
    "custom_metric_name":"queue_lag",
    "scale_out_threshold":800,
    "scale_in_threshold":150,
    "scale_out_step":3,
    "scale_in_step":1
  }'
```

### 4) Evaluate and apply

```bash
curl -sS -X POST http://localhost:8086/api/autoscaler/apps/<APP_ID>/metrics/evaluate/apply \
  -H 'Content-Type: application/json' \
  -d '{
    "cpu_percent":82,
    "memory_percent":61,
    "response_time_ms":230,
    "throughput_rps":1450,
    "custom": {
      "queue_lag": 910
    }
  }'
```

Response includes desired instances, scaling direction, reason, and estimated hourly savings.

## Notes

- This implementation is intentionally lightweight and in-memory for easy extension.
- For production CF integration, connect `POST /cf/apps/{appId}/scale` to Cloud Foundry CAPI (or CF CLI wrapper) and secure credentials via Kubernetes Secrets.
