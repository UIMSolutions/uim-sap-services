# UIM Cloud Portal Service (CPS)

Kubernetes-compatible SAP Cloud Portal Service style runtime built with D, `vibe.d`, and `uim-framework`.

## Features

- Intuitive and engaging user experience by creating sites with pages, apps, widgets, and menus using SAP Fiori 3 or custom designs
- Secure access to apps through role-based navigation and single sign-on for app types such as SAPUI5, SAP GUI for HTML, and Web Dynpro ABAP
- Central entry point to integrate and access content from SAP and non-SAP content providers uniformly
- Site administration tools for full lifecycle operations: themes, transport, translation, templates, and extensions
- Content administration tools for `apps`, `roles`, `groups`, and `catalogs`
- Embedded launchpad module support with runtime capabilities such as personalization, translation, and custom themes
- SaaS content provider exposure so business solutions can be consumed through the Cloud Portal service

## Build and Run

```bash
cd "Cloud Portal Service"
dub build
./build/uim-sap-cps-service
```

Environment variables:

- `CPS_HOST` (default `0.0.0.0`)
- `CPS_PORT` (default `8089`)
- `CPS_BASE_PATH` (default `/api/cps`)
- `CPS_SERVICE_NAME` (default `uim-sap-cps`)
- `CPS_SERVICE_VERSION` (default `1.0.0`)
- `CPS_DEFAULT_THEME` (default `sap_fiori_3`)
- `CPS_AUTH_TOKEN` (optional bearer token)

## Podman Container

```bash
cd "Cloud Portal Service"
podman build -t uim-sap-cps:local -f Dockerfile .
podman run --rm -p 8089:8089 --name uim-sap-cps uim-sap-cps:local
```

## REST API

Base path: `/api/cps`

- `GET /health`
- `GET /ready`
- `GET /v1/tenants/{tenant_id}/sites`
- `POST /v1/tenants/{tenant_id}/sites`
- `GET /v1/tenants/{tenant_id}/sites/{site_id}`
- `PUT /v1/tenants/{tenant_id}/sites/{site_id}`
- `DELETE /v1/tenants/{tenant_id}/sites/{site_id}`
- `POST /v1/tenants/{tenant_id}/navigation/resolve`
- `GET /v1/tenants/{tenant_id}/entrypoints`
- `GET /v1/tenants/{tenant_id}/admin/site-tools`
- `PUT /v1/tenants/{tenant_id}/admin/site-tools`
- `GET /v1/tenants/{tenant_id}/content/{apps|roles|groups|catalogs}`
- `POST /v1/tenants/{tenant_id}/content/{apps|roles|groups|catalogs}`
- `GET /v1/tenants/{tenant_id}/launchpad/modules`
- `POST /v1/tenants/{tenant_id}/launchpad/modules`
- `GET /v1/tenants/{tenant_id}/providers`
- `POST /v1/tenants/{tenant_id}/providers`
- `POST /v1/tenants/{tenant_id}/providers/{provider_id}/consume`

### Example: create site

```bash
curl -X POST "http://localhost:8089/api/cps/v1/tenants/acme/sites" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Acme Business Site",
    "design": "sap_fiori_3",
    "pages": [{"id": "home", "title": "Home"}],
    "widgets": [{"type": "kpi", "name": "Sales KPI"}],
    "apps": [
      {"id": "app-sales", "title": "Sales", "required_role": "sales-user", "app_type": "SAPUI5"}
    ],
    "menu": [{"title": "Home", "target": "home"}]
  }'
```

### Example: resolve role-based navigation with SSO

```bash
curl -X POST "http://localhost:8089/api/cps/v1/tenants/acme/navigation/resolve" \
  -H "Content-Type: application/json" \
  -d '{"roles": ["sales-user"]}'
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## UML Description

Note: Render the following diagrams with a PlantUML-compatible Markdown viewer/extension.

### Class Diagram

```mermaid
classDiagram
    class CPSConfig {
      +string host
      +ushort port
      +string basePath
      +string serviceName
      +string serviceVersion
      +string defaultTheme
      +bool requireAuthToken
      +string authToken
      +validate() void
    }

    class CPSSite {
      +string tenantId
      +string siteId
      +string name
      +string design
      +Json[] pages
      +Json[] widgets
      +Json[] apps
      +Json[] menu
      +toJson() Json
    }

    class CPSSiteAdministration {
      +string tenantId
      +string theme
      +bool transportEnabled
      +bool translationEnabled
      +bool templatesEnabled
      +bool extensionsEnabled
      +toJson() Json
    }

    class CPSStore {
      +upsertSite(site) CPSSite
      +listSites(tenantId) CPSSite[]
      +getSite(tenantId, siteId) Nullable!CPSSite
      +deleteSite(tenantId, siteId) bool
      +upsertSiteAdministration(admin) CPSSiteAdministration
      +getSiteAdministration(tenantId) Nullable!CPSSiteAdministration
    }

    class CPSService {
      +health() Json
      +ready() Json
      +listSites(tenantId) Json
      +upsertSite(tenantId, payload) Json
      +resolveNavigation(tenantId, payload) Json
      +listContent(tenantId, contentType) Json
      +upsertContent(tenantId, contentType, payload) Json
      +consumeProvider(tenantId, providerId) Json
    }

    class CPSServer {
      +run() void
      -handleRequest(req, res) void
      -validateAuth(req) void
      -respondError(res, message, statusCode) void
    }

    CPSServer --> CPSService : routes to
    CPSService --> CPSConfig : uses
    CPSService --> CPSStore : orchestrates
    CPSStore --> CPSSite : persists
    CPSStore --> CPSSiteAdministration : persists
```

### Sequence Diagram (Create/Update Site)

```mermaid
sequenceDiagram
    actor Admin as Portal Admin
    participant API as CPSServer
    participant Svc as CPSService
    participant Store as CPSStore

    Admin->>API: POST/PUT /v1/tenants/{tenant}/sites[/siteId]
    API->>API: validateAuth()
    API->>Svc: upsertSite(tenantId, payload)
    Svc->>Svc: validate tenant and site payload
    Svc->>Store: getSite(tenantId, siteId)
    Store-->>Svc: existing/new
    Svc->>Store: upsertSite(site)
    Store-->>Svc: persisted site
    Svc-->>API: { message, site }
    API-->>Admin: 200 OK
```

### Sequence Diagram (Role-based Navigation Resolution)

```mermaid
sequenceDiagram
    actor User as End User
    participant API as CPSServer
    participant Svc as CPSService
    participant Store as CPSStore

    User->>API: POST /v1/tenants/{tenant}/navigation/resolve
    API->>Svc: resolveNavigation(tenantId, {roles})
    Svc->>Store: listSites(tenantId)
    Store-->>Svc: tenant sites
    Svc->>Svc: filter apps/menu by required_role
    Svc-->>API: resolved entry points + SSO flags
    API-->>User: 200 OK
```

  ### Sequence Diagram (Provider Content Consumption)

  ```mermaid
  sequenceDiagram
    actor Admin as Content Admin
    participant API as CPSServer
    participant Svc as CPSService
    participant Store as CPSStore

    Admin->>API: POST /v1/tenants/{tenant}/providers/{providerId}/consume
    API->>API: validateAuth()
    API->>Svc: consumeProvider(tenantId, providerId)
    Svc->>Store: getProvider(tenantId, providerId)
    Store-->>Svc: provider config
    Svc->>Svc: fetch/transform provider content
    Svc->>Store: upsertContent(apps/roles/groups/catalogs)
    Store-->>Svc: persisted tenant content
    Svc-->>API: { message, consumed_items }
    API-->>Admin: 200 OK
  ```
