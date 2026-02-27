# UIM Credential Store-like Service (CRE)

Kubernetes-compatible service that emulates key parts of Credential Store style APIs using D, `vibe.d`, and `uim-framework`.

## Features

- Store credentials per service instance
- Retrieve credentials per service instance
- Manage service instances (create, list, get, delete)
- Create and retrieve service keys
- Encrypt credential and service-key payloads with:
  - service master key (`CRE_MASTER_KEY`)
  - caller-provided key (`X-CRE-Encryption-Key` or `encryption_key` in request body)

## Build & Run

```bash
cd cre
dub build
./build/uim-sap-cre-service
```

Environment variables:

- `CRE_HOST` (default `0.0.0.0`)
- `CRE_PORT` (default `8086`)
- `CRE_BASE_PATH` (default `/api/cre`)
- `CRE_SERVICE_NAME` (default `uim-sap-cre`)
- `CRE_SERVICE_VERSION` (default `1.0.0`)
- `CRE_AUTH_TOKEN` (optional bearer token)
- `CRE_MASTER_KEY` (default `uim-sap-cre-dev-master-key`)

## REST API

Base path: `/api/cre`

- `GET /health`
- `GET /ready`
- `GET /v1/service_instances`
- `PUT /v1/service_instances/{instance_id}`
- `GET /v1/service_instances/{instance_id}`
- `DELETE /v1/service_instances/{instance_id}`
- `PUT /v1/service_instances/{instance_id}/credentials/{credential_name}`
- `GET /v1/service_instances/{instance_id}/credentials/{credential_name}`
- `GET /v1/service_instances/{instance_id}/credentials`
- `DELETE /v1/service_instances/{instance_id}/credentials/{credential_name}`
- `PUT /v1/service_instances/{instance_id}/service_keys/{service_key_id}`
- `GET /v1/service_instances/{instance_id}/service_keys/{service_key_id}`
- `DELETE /v1/service_instances/{instance_id}/service_keys/{service_key_id}`

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
