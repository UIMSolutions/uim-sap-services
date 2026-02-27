# Site Directory Service

This service provides an BTP Site Directory-like API for managing site tiles and design-time site directory actions in a multi-tenant subaccount.

## Features

- Displays tiles for all created sites (`list site tiles`).
- Site lifecycle actions:
  - create a new site
  - delete a site
  - import a site
  - export a site
- Site alias management.
- Select a site as the default site.
- Open runtime site endpoint.
- Site settings management:
  - configure site settings
  - assign roles to the site

## Build

```bash
dub build --root="./Site Directory"
```

## Run

```bash
SDI_AUTH_TOKEN=local-token dub run --root="./Site Directory"
```

Defaults:

- Host: `0.0.0.0`
- Port: `8096`
- Base path: `/api/sitedirectory`

## API

### Ops

- `GET /api/sitedirectory/health`
- `GET /api/sitedirectory/ready`

### Site Directory

- `GET /api/sitedirectory/v1/tenants/{tenantId}/sites` (site tiles)
- `POST /api/sitedirectory/v1/tenants/{tenantId}/sites` (create)
- `GET /api/sitedirectory/v1/tenants/{tenantId}/sites/{siteId}`
- `DELETE /api/sitedirectory/v1/tenants/{tenantId}/sites/{siteId}`

### Import/Export

- `POST /api/sitedirectory/v1/tenants/{tenantId}/sites/{siteId}/import`
- `GET /api/sitedirectory/v1/tenants/{tenantId}/sites/{siteId}/export`

### Alias, Default, Runtime

- `PUT /api/sitedirectory/v1/tenants/{tenantId}/sites/{siteId}/alias`
- `PUT /api/sitedirectory/v1/tenants/{tenantId}/sites/{siteId}/default`
- `POST /api/sitedirectory/v1/tenants/{tenantId}/sites/{siteId}/runtime/open`

### Site Settings and Roles

- `GET /api/sitedirectory/v1/tenants/{tenantId}/sites/{siteId}/settings`
- `PUT /api/sitedirectory/v1/tenants/{tenantId}/sites/{siteId}/settings`
- `PUT /api/sitedirectory/v1/tenants/{tenantId}/sites/{siteId}/roles`

Create site payload example:

```json
{
  "site_id": "launchpad-main",
  "name": "Main Launchpad",
  "description": "Primary business site",
  "alias": "main",
  "is_default": true,
  "roles": ["Employee", "Manager"],
  "settings": {
    "theme": "sap_horizon",
    "home_page": "home",
    "allow_personalization": true,
    "enable_notifications": true
  }
}
```

Import payload example:

```json
{
  "name": "Imported Site",
  "description": "Imported from bundle",
  "roles": ["Employee"],
  "settings": {
    "theme": "sap_horizon_dark",
    "home_page": "workspace"
  },
  "bundle": {
    "pages": ["home", "approvals"],
    "catalogs": ["finance", "hr"]
  }
}
```

## Podman

```bash
podman build -t uim-sap-sdi:latest "./Site Directory"
podman run --rm -p 8096:8096 \
  -e SDI_AUTH_TOKEN=local-token \
  uim-sap-sdi:latest
```

## Kubernetes

```bash
kubectl apply -f "./Site Directory/k8s/configmap.yaml"
kubectl apply -f "./Site Directory/k8s/deployment.yaml"
kubectl apply -f "./Site Directory/k8s/service.yaml"
```

Optional auth secret:

```bash
kubectl create secret generic uim-sap-sdi-secret \
  --from-literal=authToken=local-token
```
