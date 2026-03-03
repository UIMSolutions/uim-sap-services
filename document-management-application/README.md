# UIM Document Management Service, Application Option

Standalone, ready-to-use web application that provides document management capabilities for enterprise content. Built with **Dlang**, **vibe.d**, and **uim-framework**, containerized with **Podman** and deployable to **Kubernetes**.

## Features and Use-Cases

- **Manage files and folders** — Create, edit, download, and delete files and folders. Navigate the file and folder hierarchy using breadcrumbs.
- **Connect to your business storage** — Bring your choice of CMIS-compliant, on-premise or cloud repository and leverage the application's capabilities.
- **View your documents** — View images, PDFs, and vector graphics using the built-in viewers. Other file types are available for download.
- **Restructure your document hierarchy** — Move and copy folders and documents to other folders within your repository.
- **Manage metadata** — View and edit document attributes and folder properties supported by your repository.
- **Personalize the user interface** — Customize your document list by sorting based on document attributes (name, size, date, type).
- **Manage document versions and status** — Create one or more versions for the base version of a file. Check-out/check-in workflow prevents unintentional changes.
- **Support for encryption** — Use encryption while onboarding internal repositories. Data is stored encrypted on the backend with service-managed encryption keys.
- **SAP storage integration** — Use with Document Management Service, Repository Option to securely store and manage your business documents.

## Build and Run

```bash
cd document-management-application
dub build
./build/uim-sap-document-management-service
```

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `DMS_HOST` | `0.0.0.0` | Bind address |
| `DMS_PORT` | `8090` | Listen port |
| `DMS_BASE_PATH` | `/api/docmgmt` | API base path |
| `DMS_SERVICE_NAME` | `uim-sap-document-management` | Service identifier |
| `DMS_SERVICE_VERSION` | `1.0.0` | Service version |
| `DMS_MAX_UPLOAD_SIZE_MB` | `100` | Maximum upload size in MB |
| `DMS_DEFAULT_REPOSITORY` | `internal` | Default repository name |
| `DMS_VERSIONING_ENABLED` | `true` | Enable document versioning |
| `DMS_ENCRYPTION_ENABLED` | `false` | Enable at-rest encryption |
| `DMS_ENCRYPTION_KEY` | *(none)* | Base64 encryption key (required when encryption enabled) |
| `DMS_AUTH_TOKEN` | *(none)* | Bearer token for API authentication |

## Podman

```bash
cd document-management-application
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

Diagrams available in `docs/uml/`:

- `docs/uml/component-architecture.puml`
- `docs/uml/class-model.puml`
- `docs/uml/sequence-document-lifecycle.puml`

Render helpers:

```bash
make uml-check
make uml
make uml-svg
make uml-clean
```

## REST API

Base path: `/api/docmgmt`

### Platform

| Method | Path | Description |
|---|---|---|
| `GET` | `/health` | Health check |
| `GET` | `/ready` | Readiness probe |

### Repositories

| Method | Path | Description |
|---|---|---|
| `GET` | `/v1/repositories` | List connected repositories |
| `POST` | `/v1/repositories` | Connect a new CMIS repository |
| `GET` | `/v1/repositories/{id}` | Get repository details |
| `DELETE` | `/v1/repositories/{id}` | Disconnect a repository |
| `GET` | `/v1/repositories/{id}/contents?folder_id=` | List folder contents (files + folders) |
| `POST` | `/v1/repositories/{id}/contents/sorted` | List documents sorted by attribute |
| `POST` | `/v1/repositories/{id}/folders` | Create a folder |
| `POST` | `/v1/repositories/{id}/documents` | Create/upload a document |

### Folders

| Method | Path | Description |
|---|---|---|
| `GET` | `/v1/folders/{id}` | Get folder with breadcrumbs |
| `PUT` | `/v1/folders/{id}` | Update folder |
| `DELETE` | `/v1/folders/{id}` | Delete folder (and descendants) |
| `POST` | `/v1/folders/{id}/move` | Move folder to new parent |
| `POST` | `/v1/folders/{id}/copy` | Copy folder to new parent |
| `GET` | `/v1/folders/{id}/properties` | Get folder metadata/properties |
| `PUT` | `/v1/folders/{id}/properties` | Update folder metadata/properties |

### Documents

| Method | Path | Description |
|---|---|---|
| `GET` | `/v1/documents/{id}` | Get document details |
| `PUT` | `/v1/documents/{id}` | Update document |
| `DELETE` | `/v1/documents/{id}` | Delete document |
| `POST` | `/v1/documents/{id}/move` | Move document to another folder |
| `POST` | `/v1/documents/{id}/copy` | Copy document to another folder |
| `GET` | `/v1/documents/{id}/view` | View document (built-in viewer) |
| `GET` | `/v1/documents/{id}/download` | Download document content |
| `GET` | `/v1/documents/{id}/metadata` | Get document metadata |
| `PUT` | `/v1/documents/{id}/metadata` | Update document metadata |

### Versioning

| Method | Path | Description |
|---|---|---|
| `GET` | `/v1/documents/{id}/versions` | List all versions |
| `POST` | `/v1/documents/{id}/versions` | Create a new version |
| `GET` | `/v1/documents/{id}/versions/{verId}` | Get specific version |

### Workflow (Check-out / Check-in)

| Method | Path | Description |
|---|---|---|
| `POST` | `/v1/documents/{id}/checkout` | Check out document |
| `POST` | `/v1/documents/{id}/checkin` | Check in document (creates new version) |
| `POST` | `/v1/documents/{id}/cancel-checkout` | Cancel check-out |

### Encryption

| Method | Path | Description |
|---|---|---|
| `GET` | `/v1/encryption/status` | Get encryption configuration status |

## Architecture

```
┌──────────────────────────────────────────────────────┐
│               DocumentManagementServer               │
│                 (vibe.d HTTP Router)                  │
├──────────────────────────────────────────────────────┤
│             DocumentManagementService                │
│   (Business Logic: CRUD, Versions, Workflow, etc.)   │
├──────────┬──────────────┬────────────────────────────┤
│  Store   │  Encryption  │  RepositoryRegistry        │
│ (Memory) │   Manager    │  (CMIS Connectors)         │
└──────────┴──────────────┴────────────────────────────┘
```

## License

Apache-2.0 — see [LICENSE](LICENSE).
