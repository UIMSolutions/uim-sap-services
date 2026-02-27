# UIM Agentry-like Service

Agentry mobile applications extend backend functionality to mobile users. This service provides a development and operations runtime to build, test, manage, and consume Agentry-style mobile services using Dlang, `vibe.d`, and `uim-framework`.

## Features and Use-Cases

- **Mobile app development management**: register and manage mobile apps per tenant.
- **Versioning and release handling**: create app versions with changelogs and build status.
- **Test operations**: trigger and track test runs for app versions in environments (for example QA/UAT).
- **Runtime operations**: manage runtime instances and deploy specific versions.
- **Mobile consumption support**: register devices and perform sync operations.
- **Backend consumption**: configure backend systems consumed by mobile applications.
- **Operations visibility**: dashboard summary for apps, instances, devices, and backend connectivity.

## Build and run

```bash
cd "Agentry"
dub build
./build/uim-sap-agentry-service
```

Environment variables:

- `AGENTRY_HOST` (default `0.0.0.0`)
- `AGENTRY_PORT` (default `8089`)
- `AGENTRY_BASE_PATH` (default `/api/agentry`)
- `AGENTRY_SERVICE_NAME` (default `uim-sap-agentry`)
- `AGENTRY_SERVICE_VERSION` (default `1.0.0`)
- `AGENTRY_DEFAULT_BACKEND` (default `s4-primary`)
- `AGENTRY_AUTH_TOKEN` (optional bearer token)

## Podman

```bash
cd "Agentry"
chmod +x build/podman-run.sh
./build/podman-run.sh
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
- `docs/uml/sequence-dev-test-operate.puml`

Render helpers:

```bash
make uml-check
make uml
make uml-svg
make uml-clean
```

## REST API

Base path: `/api/agentry`

### Platform

- `GET /health`
- `GET /ready`

### Development

- `GET /v1/tenants/{tenant_id}/mobile-apps`
- `POST /v1/tenants/{tenant_id}/mobile-apps`
- `GET /v1/tenants/{tenant_id}/mobile-apps/{app_id}/versions`
- `POST /v1/tenants/{tenant_id}/mobile-apps/{app_id}/versions`

### Testing

- `GET /v1/tenants/{tenant_id}/mobile-apps/{app_id}/test-runs`
- `POST /v1/tenants/{tenant_id}/mobile-apps/{app_id}/test-runs`

### Operations

- `GET /v1/tenants/{tenant_id}/operations-instances`
- `POST /v1/tenants/{tenant_id}/operations-instances`
- `POST /v1/tenants/{tenant_id}/operations-instances/{instance_id}/deploy`
- `GET /v1/tenants/{tenant_id}/operations/dashboard`

### Mobile Consumption

- `GET /v1/tenants/{tenant_id}/devices`
- `POST /v1/tenants/{tenant_id}/devices`
- `POST /v1/tenants/{tenant_id}/devices/{device_id}/sync`

### Backend Service Consumption

- `GET /v1/tenants/{tenant_id}/backend-systems`
- `POST /v1/tenants/{tenant_id}/backend-systems`

## Example flow

```bash
# 1) Create mobile app
curl -X POST "http://localhost:8089/api/agentry/v1/tenants/acme/mobile-apps" \
  -H "Content-Type: application/json" \
  -d '{"name":"field-service-mobile","owner_team":"mobility","backend_system":"s4-primary"}'

# 2) Create app version
curl -X POST "http://localhost:8089/api/agentry/v1/tenants/acme/mobile-apps/<APP_ID>/versions" \
  -H "Content-Type: application/json" \
  -d '{"version_label":"1.0.1","change_log":"work order sync improvements"}'

# 3) Trigger test run
curl -X POST "http://localhost:8089/api/agentry/v1/tenants/acme/mobile-apps/<APP_ID>/test-runs" \
  -H "Content-Type: application/json" \
  -d '{"version_id":"<VERSION_ID>","environment":"qa","result_status":"passed","passed_cases":112,"failed_cases":3}'

# 4) Create runtime instance and deploy
curl -X POST "http://localhost:8089/api/agentry/v1/tenants/acme/operations-instances" \
  -H "Content-Type: application/json" \
  -d '{"app_id":"<APP_ID>","target_environment":"prod"}'

curl -X POST "http://localhost:8089/api/agentry/v1/tenants/acme/operations-instances/<INSTANCE_ID>/deploy" \
  -H "Content-Type: application/json" \
  -d '{"version_id":"<VERSION_ID>","status":"running"}'

# 5) Register device and sync
curl -X POST "http://localhost:8089/api/agentry/v1/tenants/acme/devices" \
  -H "Content-Type: application/json" \
  -d '{"app_id":"<APP_ID>","user_id":"u12345","platform":"android","app_version_id":"<VERSION_ID>"}'

curl -X POST "http://localhost:8089/api/agentry/v1/tenants/acme/devices/<DEVICE_ID>/sync" \
  -H "Content-Type: application/json" \
  -d '{"app_version_id":"<VERSION_ID>"}'
```
