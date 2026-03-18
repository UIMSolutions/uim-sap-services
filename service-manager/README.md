# Service Manager Service

`service-manager` is a D + vibe.d + UIM-framework microservice that emulates key capabilities of SAP Service Manager on SAP BTP.

## Features

- Service Marketplace overview and service discovery.
- Platform management to register runtime environments and enable native service consumption.
- Service instance lifecycle management (provision, update, deprovision patterns).
- Service binding management for access credentials and connectivity metadata.
- Service instance sharing across environments.
- Runtime instance management via API actions.

## Run locally

```bash
cd service-manager
dub run
```

Defaults:

- Host: `0.0.0.0`
- Port: `8111`
- Base path: `/api/service-manager`

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

Base: `/api/service-manager/v1`

- `GET /discovery`
- `GET /marketplace/offerings`
- `GET /tenants/{tenantId}/service-offerings`
- `GET|POST /tenants/{tenantId}/platforms`
- `DELETE /tenants/{tenantId}/platforms/{platformId}`
- `GET|POST /tenants/{tenantId}/service-instances`
- `PATCH|DELETE /tenants/{tenantId}/service-instances/{instanceId}`
- `POST /tenants/{tenantId}/service-instances/{instanceId}/shares`
- `GET|POST /tenants/{tenantId}/service-bindings`
- `DELETE /tenants/{tenantId}/service-bindings/{bindingId}`
- `POST /tenants/{tenantId}/runtime/instances/{instanceId}/actions/{action}`

## Example flow

1. Register a platform:

```bash
curl -X POST http://localhost:8111/api/service-manager/v1/tenants/acme/platforms \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "acme-kyma-cluster",
    "runtime_type": "kubernetes",
    "api_endpoint": "https://cluster.acme.example"
  }'
```

1. Provision a service instance:

```bash
curl -X POST http://localhost:8111/api/service-manager/v1/tenants/acme/service-instances \
  -H 'Content-Type: application/json' \
  -d '{
    "offering_name": "hana-cloud",
    "plan_name": "standard",
    "environment_id": "env-dev",
    "platform_id": "platform-1"
  }'
```

1. Create a service binding:

```bash
curl -X POST http://localhost:8111/api/service-manager/v1/tenants/acme/service-bindings \
  -H 'Content-Type: application/json' \
  -d '{
    "instance_id": "instance-1",
    "name": "hana-binding",
    "environment_id": "env-dev",
    "credentials_ref": "secret://hana-binding"
  }'
```

1. Trigger runtime action:

```bash
curl -X POST http://localhost:8111/api/service-manager/v1/tenants/acme/runtime/instances/instance-1/actions/suspend
```
