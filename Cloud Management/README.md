# UIM  Cloud Management Service for SAP BTP (MGT)

Kubernetes-compatible SAP BTP cloud management service built with D, `vibe.d`, and `uim-framework`.

## Features

- Health and readiness endpoints
- SAP BTP management proxy endpoints for:
  - environments
  - subaccounts
  - organizations
  - spaces
  - applications
  - services
  - service instances
  - destinations
- Optional bearer token protection for incoming requests (`MGT_AUTH_TOKEN`)
- Supports SAP BTP Basic auth and OAuth2-based upstream authentication

## Build & Run (Local)

```bash
cd mgt
dub build
MGT_BTP_SUBDOMAIN=<your-subdomain> \
MGT_BTP_USERNAME=<user> \
MGT_BTP_PASSWORD=<pass> \
./build/uim-sap-mgt-service
```

## Podman Image

Build from repository root so the Docker build context includes the sibling `btp` package:

```bash
cd ..
podman build -f mgt/Dockerfile -t localhost/uim-sap-mgt:latest .
```

Run:

```bash
podman run --rm -p 8088:8088 \
  -e MGT_BTP_SUBDOMAIN=<your-subdomain> \
  -e MGT_BTP_USE_OAUTH2=true \
  -e MGT_BTP_ACCESS_TOKEN=<token> \
  localhost/uim-sap-mgt:latest
```

## Environment Variables

- Service:
  - `MGT_HOST` (default `0.0.0.0`)
  - `MGT_PORT` (default `8088`)
  - `MGT_BASE_PATH` (default `/api/mgt`)
  - `MGT_SERVICE_NAME` (default `uim-sap-mgt`)
  - `MGT_SERVICE_VERSION` (default `1.0.0`)
  - `MGT_AUTH_TOKEN` (optional bearer token)
- SAP BTP:
  - `MGT_BTP_TENANT` (optional)
  - `MGT_BTP_SUBDOMAIN` (required)
  - `MGT_BTP_REGION` (default `api.sap.hana.ondemand.com`)
  - `MGT_BTP_USE_OAUTH2` (`true`/`false`, default `false`)
  - Basic auth: `MGT_BTP_USERNAME`, `MGT_BTP_PASSWORD`
  - OAuth2: `MGT_BTP_ACCESS_TOKEN` or (`MGT_BTP_CLIENT_ID` and `MGT_BTP_CLIENT_SECRET`)

## REST API

Base path: `/api/mgt`

- `GET /health`
- `GET /ready`
- `GET /v1/environments`
- `GET /v1/subaccounts`
- `GET /v1/organizations`
- `GET /v1/spaces`
- `GET /v1/applications`
- `GET /v1/applications/{guid}`
- `GET /v1/services`
- `GET /v1/service_instances`
- `GET /v1/destinations`
- `GET /v1/destinations/{name}`

## Kubernetes

```bash
kubectl apply -f mgt/k8s/configmap.yaml
kubectl apply -f mgt/k8s/deployment.yaml
kubectl apply -f mgt/k8s/service.yaml
```
