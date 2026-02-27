````markdown
# UIM Authorization and Trust Management Service (ATM)

Authorization and trust management service inspired by Authorization and Trust Management, built with Dlang, `vibe.d`, and `uim-framework`, deployable with Podman and Kubernetes.

## What it supports

- **Use corporate or default IdP**: tenant-scoped trust configuration with a preconfigured ID service style default IdP and support for switching to corporate IdPs
- **External authentication handling**: validates bearer JWT claims (`iss`, `aud`, `sub`, `exp`) against trusted IdP configuration
- **Role-based access**: technical roles with permissions and business-level role collections
- **User authorization assignments**: map external users to role collections without storing credentials
- **Application authorization decision**: checks required permissions for app access at runtime

## Build and run

```bash
cd "Authorization and Trust Management"
dub build
./build/uim-sap-atm-service
```

Environment variables:

- `ATM_HOST` (default `0.0.0.0`)
- `ATM_PORT` (default `8088`)
- `ATM_BASE_PATH` (default `/api/atm`)
- `ATM_SERVICE_NAME` (default `uim-sap-atm`)
- `ATM_SERVICE_VERSION` (default `1.0.0`)
- `ATM_DEFAULT_IDP_NAME` (default `sap-id-service`)
- `ATM_DEFAULT_IDP_ISSUER` (default `https://accounts.sap.com`)
- `ATM_DEFAULT_IDP_AUDIENCE` (default `uim-sap-app`)
- `ATM_ALLOW_UNSIGNED_TOKENS` (default `true`)
- `ATM_ENFORCE_TOKEN_EXPIRY` (default `true`)
- `ATM_BOOTSTRAP_TOKEN` (optional token for initial admin bootstrap via `X-Bootstrap-Token`)

## Podman

```bash
cd "Authorization and Trust Management"
chmod +x build/podman-run.sh
./build/podman-run.sh
```

Or direct run:

```bash
podman build -t uim-sap-atm:local .
podman run --rm -p 8088:8088 uim-sap-atm:local
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.example.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## REST API

Base path: `/api/atm`

### Platform

- `GET /health`
- `GET /ready`

### Session and authorization

- `GET /v1/tenants/{tenant_id}/auth` (resolve current session from bearer token)
- `POST /v1/tenants/{tenant_id}/apps/{app_id}/authorize`

### Identity providers (admin)

- `GET /v1/tenants/{tenant_id}/idps`
- `PUT /v1/tenants/{tenant_id}/idps/{idp_id}`
- `POST /v1/tenants/{tenant_id}/idps/{idp_id}/default`

### Technical roles and role collections (admin)

- `GET /v1/tenants/{tenant_id}/roles/technical`
- `PUT /v1/tenants/{tenant_id}/roles/technical/{role_id}`
- `GET /v1/tenants/{tenant_id}/role-collections`
- `PUT /v1/tenants/{tenant_id}/role-collections/{collection_id}`

### User assignments (admin)

- `GET /v1/tenants/{tenant_id}/users/{user_id}/assignments`
- `PUT /v1/tenants/{tenant_id}/users/{user_id}/assignments`

## Use case 1: use default IdP, then switch to corporate IdP

### A) Inspect default IdP (bootstrap admin)

```bash
curl "http://localhost:8088/api/atm/v1/tenants/acme/idps" \
  -H "X-Bootstrap-Token: change-me"
```

### B) Add corporate IdP

```bash
curl -X PUT "http://localhost:8088/api/atm/v1/tenants/acme/idps/corp-idp" \
  -H "Content-Type: application/json" \
  -H "X-Bootstrap-Token: change-me" \
  -d '{
    "name": "acme-corporate-idp",
    "provider_type": "oidc",
    "issuer": "https://idp.acme.example.com",
    "audience": "uim-acme-app",
    "enabled": true,
    "trusted_algorithms": ["RS256", "ES256"]
  }'
```

### C) Switch default to corporate IdP

```bash
curl -X POST "http://localhost:8088/api/atm/v1/tenants/acme/idps/corp-idp/default" \
  -H "X-Bootstrap-Token: change-me"
```

## Use case 2: technical roles -> role collections -> app access

### A) Create technical role for app access

```bash
curl -X PUT "http://localhost:8088/api/atm/v1/tenants/acme/roles/technical/AppViewer" \
  -H "Content-Type: application/json" \
  -H "X-Bootstrap-Token: change-me" \
  -d '{
    "name": "Application Viewer",
    "permissions": ["app.access.read"]
  }'
```

### B) Aggregate into business role collection

```bash
curl -X PUT "http://localhost:8088/api/atm/v1/tenants/acme/role-collections/BusinessReaders" \
  -H "Content-Type: application/json" \
  -H "X-Bootstrap-Token: change-me" \
  -d '{
    "name": "Business Readers",
    "technical_role_ids": ["AppViewer"]
  }'
```

### C) Assign role collection to external user subject

```bash
curl -X PUT "http://localhost:8088/api/atm/v1/tenants/acme/users/alice/assignments" \
  -H "Content-Type: application/json" \
  -H "X-Bootstrap-Token: change-me" \
  -d '{
    "idp_id": "corp-idp",
    "role_collection_ids": ["BusinessReaders"]
  }'
```

### D) Authorize application access with bearer token

```bash
curl -X POST "http://localhost:8088/api/atm/v1/tenants/acme/apps/sales-dashboard/authorize" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <JWT_FOR_SUB_ALICE>" \
  -d '{"required_permissions": ["app.access.read"]}'
```

````
