# UIM Document Management Service, Integration Option

Build document management capabilities for business applications using integration APIs
and a reusable UI5-based component. Multi-tenant architecture with CMIS-compliant repository
support and encryption at rest.

Built with **D (Dlang)**, **vibe.d** and the **UIM Framework**.

---

## Features

| Category | Capability |
|----------|-----------|
| **Multi-tenancy** | Full tenant isolation — every resource is scoped to a tenant |
| **Integration APIs** | Tenant-scoped REST endpoints to embed document management into business apps |
| **Integration Links** | Bind external business objects (e.g. Sales Orders) to documents |
| **Embeddable UI Component** | Configurable UI5-style component (theme, locale, feature toggles) |
| **CMIS Repositories** | Connect any OASIS CMIS-compliant repository (on-prem or cloud) |
| **File & Folder CRUD** | Create, read, update, delete with hierarchy navigation |
| **Breadcrumb Navigation** | Automatic breadcrumb trail from any folder to root |
| **Move & Copy** | Move/copy documents and folders across the hierarchy |
| **Versioning** | Automatic version tracking with major/minor labels |
| **Check-out / Check-in** | Pessimistic locking workflow for concurrent editing |
| **Metadata Management** | Custom properties on documents and folders |
| **Encryption at Rest** | XOR-SHA256-derived encryption for internal repository content |
| **Sorting** | Sort documents by name, size, date, MIME type |
| **Built-in Viewer** | Detect viewable content (PDF, images, SVG) |

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│          DocMgmtIntegrationServer (vibe.d)          │
│  /api/docmgmt-integration/v1/tenants/{tid}/...      │
├─────────────────────────────────────────────────────┤
│          DocMgmtIntegrationService                  │
│  Tenant CRUD │ Repos │ Folders │ Documents │ Links  │
│  UI Component Config │ Versioning │ Check-out/in    │
├───────────┬───────────┬─────────────────────────────┤
│ Encryption│ Registry  │  DocMgmtIntegrationStore    │
│ Manager   │ (CMIS)    │  (Tenants, Repos, Folders,  │
│           │           │   Docs, Versions, Links,    │
│           │           │   UIConfigs, Content)        │
└───────────┴───────────┴─────────────────────────────┘
```

---

## Quick Start

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DMSI_HOST` | `0.0.0.0` | Bind address |
| `DMSI_PORT` | `8091` | Listen port |
| `DMSI_BASE_PATH` | `/api/docmgmt-integration` | URL base path |
| `DMSI_SERVICE_NAME` | `uim-sap-docmgmt-integration` | Service identifier |
| `DMSI_SERVICE_VERSION` | `1.0.0` | Reported version |
| `DMSI_MAX_UPLOAD_SIZE_MB` | `100` | Maximum upload size |
| `DMSI_DEFAULT_REPOSITORY` | `internal` | Name for the auto-created repository |
| `DMSI_VERSIONING_ENABLED` | `true` | Enable version tracking |
| `DMSI_ENCRYPTION_ENABLED` | `false` | Enable content encryption |
| `DMSI_ENCRYPTION_KEY` | *(empty)* | Base64 key material (required if encryption enabled) |
| `DMSI_MULTITENANCY_ENABLED` | `true` | Enforce tenant isolation |
| `DMSI_AUTH_TOKEN` | *(empty)* | Bearer token (enables auth when set) |

### Build & Run (dub)

```bash
dub build
./build/uim-sap-docmgmt-integration-service
```

### Build & Run (Podman)

```bash
podman build -t uim-sap-docmgmt-integration .
bash build/podman-run.sh
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.example.yaml   # edit first!
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## API Reference

All tenant-scoped endpoints are prefixed with:
```
/api/docmgmt-integration/v1/tenants/{tenantId}
```

### Platform

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health probe |
| GET | `/ready` | Readiness probe |
| GET | `/v1/encryption/status` | Encryption configuration |

### Tenants

| Method | Path | Description |
|--------|------|-------------|
| POST | `/v1/tenants` | Register a new tenant |
| GET | `/v1/tenants` | List all tenants |
| GET | `/v1/tenants/{tid}` | Get tenant details |
| PUT | `/v1/tenants/{tid}` | Update tenant |
| DELETE | `/v1/tenants/{tid}` | Delete tenant and all data |

### Repositories

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/tenants/{tid}/repositories` | List repositories |
| POST | `/v1/tenants/{tid}/repositories` | Connect external CMIS repo |
| GET | `/v1/tenants/{tid}/repositories/{rid}` | Get repository info |
| DELETE | `/v1/tenants/{tid}/repositories/{rid}` | Disconnect repository |

### Folders

| Method | Path | Description |
|--------|------|-------------|
| POST | `/v1/tenants/{tid}/repositories/{rid}/folders` | Create folder |
| GET | `/v1/tenants/{tid}/folders/{fid}` | Get folder + breadcrumbs |
| PUT | `/v1/tenants/{tid}/folders/{fid}` | Update folder |
| DELETE | `/v1/tenants/{tid}/folders/{fid}` | Delete folder tree |
| POST | `/v1/tenants/{tid}/folders/{fid}/move` | Move folder |
| POST | `/v1/tenants/{tid}/folders/{fid}/copy` | Copy folder |
| GET | `/v1/tenants/{tid}/folders/{fid}/properties` | Get properties |
| PUT | `/v1/tenants/{tid}/folders/{fid}/properties` | Update properties |
| GET | `/v1/tenants/{tid}/repositories/{rid}/contents?folder_id=` | List folder contents |
| POST | `/v1/tenants/{tid}/repositories/{rid}/contents/sorted` | Sorted listing |

### Documents

| Method | Path | Description |
|--------|------|-------------|
| POST | `/v1/tenants/{tid}/repositories/{rid}/documents` | Create document |
| GET | `/v1/tenants/{tid}/documents/{did}` | Get document |
| PUT | `/v1/tenants/{tid}/documents/{did}` | Update document |
| DELETE | `/v1/tenants/{tid}/documents/{did}` | Delete document |
| POST | `/v1/tenants/{tid}/documents/{did}/move` | Move document |
| POST | `/v1/tenants/{tid}/documents/{did}/copy` | Copy document |
| GET | `/v1/tenants/{tid}/documents/{did}/view` | View (viewer type) |
| GET | `/v1/tenants/{tid}/documents/{did}/download` | Download content |
| GET | `/v1/tenants/{tid}/documents/{did}/metadata` | Get metadata |
| PUT | `/v1/tenants/{tid}/documents/{did}/metadata` | Update metadata |

### Versioning

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/tenants/{tid}/documents/{did}/versions` | List versions |
| POST | `/v1/tenants/{tid}/documents/{did}/versions` | Create version |
| GET | `/v1/tenants/{tid}/documents/{did}/versions/{vid}` | Get version |
| POST | `/v1/tenants/{tid}/documents/{did}/checkout` | Check out |
| POST | `/v1/tenants/{tid}/documents/{did}/checkin` | Check in |
| POST | `/v1/tenants/{tid}/documents/{did}/cancel-checkout` | Cancel check-out |

### Integration Links

| Method | Path | Description |
|--------|------|-------------|
| POST | `/v1/tenants/{tid}/links` | Create integration link |
| GET | `/v1/tenants/{tid}/links` | List links (supports `?external_object_type=&external_object_id=`) |
| GET | `/v1/tenants/{tid}/links/{lid}` | Get link |
| DELETE | `/v1/tenants/{tid}/links/{lid}` | Delete link |
| GET | `/v1/tenants/{tid}/documents/{did}/links` | Links for a document |

### Embedded UI Component

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/tenants/{tid}/ui-component` | Get UI component config |
| PUT | `/v1/tenants/{tid}/ui-component` | Set/update UI component config |
| DELETE | `/v1/tenants/{tid}/ui-component` | Remove UI component config |

---

## UML Documentation

PlantUML diagrams live in `docs/uml/`:

- **component-architecture.puml** — high-level system components
- **class-model.puml** — class and struct relationships
- **sequence-integration-lifecycle.puml** — tenant registration, document creation, linking, and check-out/check-in flows

Generate PNG/SVG:
```bash
make uml-png   # or: make uml-svg
```

---

## Project Structure

```
document-management-integration/
├── dub.sdl                         # Build configuration
├── Dockerfile                      # Multi-stage container build
├── Makefile                        # PlantUML helpers
├── build/
│   └── podman-run.sh               # Podman launcher script
├── k8s/
│   ├── configmap.yaml              # Environment configuration
│   ├── secret.example.yaml         # Secrets template
│   ├── deployment.yaml             # 2-replica deployment + PVC
│   └── service.yaml                # ClusterIP service
├── docs/uml/
│   ├── component-architecture.puml
│   ├── class-model.puml
│   └── sequence-integration-lifecycle.puml
└── source/
    ├── app.d                       # Entry point (reads DMSI_* env vars)
    └── uim/sap/docmgmtintegration/
        ├── package.d               # Module façade
        ├── config.d                # DocMgmtIntegrationConfig
        ├── encryption.d            # EncryptionManager
        ├── repositories.d          # IRepositoryConnector, Registry
        ├── store.d                 # DocMgmtIntegrationStore (tenant-aware)
        ├── service.d               # DocMgmtIntegrationService (business logic)
        ├── server.d                # DocMgmtIntegrationServer (REST router)
        ├── exceptions/
        │   └── package.d           # Exception hierarchy
        ├── models/
        │   ├── package.d
        │   └── models.d            # Tenant, Repository, Folder, Document,
        │                           # DocumentVersion, Breadcrumb,
        │                           # UIComponentConfig, IntegrationLink
        └── helpers/
            └── package.d           # Placeholder for future helpers
```

---

## License

Apache-2.0 — see [LICENSE](LICENSE).
