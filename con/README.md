# UIM SAP Connectivity Service (CON)

Kubernetes-compatible SAP Connectivity Service style bridge built with D, `vibe.d`, and `uim-framework`.

## Features

- Access on-premise systems from cloud workloads through a connector-tunnel routing model
- Easier, faster hybrid deployment than traditional reverse proxy patterns, with no firewall rule changes required by this service
- Multiple supported protocols for cloud-to-on-prem communication: `HTTP`, `RFC`, `TCP`
- Cloud database access via `JDBC` and `ODBC` destinations that can be consumed like local endpoints
- Cloud user identity propagation to downstream targets using forwarded user principals (`X-Cloud-User`)
- Multitenancy support for tenant-aware applications running in shared compute units

## Build and Run

```bash
cd con
dub build
./build/uim-sap-con-service
```

Environment variables:

- `CON_HOST` (default `0.0.0.0`)
- `CON_PORT` (default `8085`)
- `CON_BASE_PATH` (default `/api/con`)
- `CON_SERVICE_NAME` (default `uim-sap-con`)
- `CON_SERVICE_VERSION` (default `1.0.0`)
- `CON_CONNECTOR_LOCATION_ID` (default `default-location`)
- `CON_AUTH_TOKEN` (optional bearer token)

## Podman Container

Build and run with Podman:

```bash
cd con
podman build -t uim-sap-con:local -f Dockerfile .
podman run --rm -p 8085:8085 --name uim-sap-con uim-sap-con:local
```

## REST API

Base path: `/api/con`

- `GET /health`
- `GET /ready`
- `GET /v1/protocols`
- `GET /v1/tenants`
- `GET /v1/tenants/{tenant_id}/destinations`
- `PUT /v1/tenants/{tenant_id}/destinations/{destination_name}`
- `GET /v1/tenants/{tenant_id}/destinations/{destination_name}`
- `DELETE /v1/tenants/{tenant_id}/destinations/{destination_name}`
- `POST /v1/tenants/{tenant_id}/connect/{destination_name}`
- `GET /v1/tenants/{tenant_id}/cloud-databases`

### Example: register destination

```bash
curl -X PUT "http://localhost:8085/api/con/v1/tenants/acme/destinations/erp-rfc" \
  -H "Content-Type: application/json" \
  -d '{
    "protocol": "rfc",
    "target_host": "erp.internal.local",
    "target_port": 3300,
    "on_premise": true,
    "identity_propagation_enabled": true
  }'
```

### Example: connect with principal propagation

```bash
curl -X POST "http://localhost:8085/api/con/v1/tenants/acme/connect/erp-rfc" \
  -H "Content-Type: application/json" \
  -H "X-Cloud-User: user@example.com" \
  -d '{"forward_identity": true}'
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
