# Object Store on SAP BTP — UIM Service

Object store service for SAP BTP, built with D, the UIM framework, and vibe.d. Lets you store and manage objects with creation, upload, download, and deletion. Supports IaaS layers including AWS S3, Azure Blob Storage, and Google Cloud Storage.

## Features

- **Multi-Cloud Support** — AWS S3 buckets, Azure Blob containers, and Google Cloud Storage buckets
- **Bucket Management** — create, update, suspend, delete storage buckets with configurable storage classes and replication
- **Object Operations** — upload, download (with base64 content), head (metadata only), list (with prefix filtering), and delete objects
- **Secure Credentials** — automatic credential issuance (access key + secret) per bucket; revoke on demand
- **Versioning** — optional object versioning with version history and delete markers
- **Bucket Policies** — fine-grained access control with allowed actions, key prefixes, and principals
- **Storage Classes** — STANDARD, NEARLINE, COLDLINE, ARCHIVE tiers
- **Replication** — none, single-region, or multi-region durability
- **Encryption** — encryption enabled by default for all buckets
- **Scalability** — configurable quotas for buckets, objects per bucket, object size, and bucket storage
- **Metrics** — aggregate statistics on buckets, objects, storage, credentials, and policies

## Configuration

| Variable | Default | Description |
|---|---|---|
| `OBS_HOST` | `0.0.0.0` | Listen address |
| `OBS_PORT` | `8091` | Listen port |
| `OBS_BASE_PATH` | `/api/obs` | API base path |
| `OBS_SERVICE_NAME` | `uim-obs` | Service identifier |
| `OBS_AUTH_TOKEN` | *(empty)* | Bearer token for API auth |
| `OBS_MAX_BUCKETS` | `500` | Maximum buckets |
| `OBS_MAX_OBJECTS_PER_BUCKET` | `100000` | Max objects per bucket |
| `OBS_MAX_OBJECT_SIZE` | `104857600` | Max single object size (bytes, 100 MB) |
| `OBS_MAX_BUCKET_STORAGE` | `10737418240` | Max bucket storage (bytes, 10 GB) |
| `OBS_DEFAULT_PROVIDER` | `aws` | Default IaaS provider (aws/azure/gcp) |
| `OBS_DEFAULT_REGION` | `eu-central-1` | Default region |
| `OBS_DEFAULT_VERSIONING` | `false` | Enable versioning by default |

## API Endpoints

### Buckets

| Method | Path | Description |
|---|---|---|
| GET | `/api/obs/v1/buckets` | List all buckets |
| POST | `/api/obs/v1/buckets` | Create a bucket |
| GET | `/api/obs/v1/buckets/{id}` | Get bucket details |
| PUT | `/api/obs/v1/buckets/{id}` | Update bucket |
| DELETE | `/api/obs/v1/buckets/{id}` | Delete bucket (and all contents) |
| POST | `/api/obs/v1/buckets/{id}/suspend` | Suspend a bucket |

### Objects

| Method | Path | Description |
|---|---|---|
| GET | `/api/obs/v1/buckets/{id}/objects` | List objects (query: `?prefix=...`) |
| POST | `/api/obs/v1/buckets/{id}/objects` | Upload an object |
| GET | `/api/obs/v1/buckets/{id}/objects/{key}` | Download object (metadata + content) |
| HEAD | `/api/obs/v1/buckets/{id}/objects/{key}` | Get object metadata |
| DELETE | `/api/obs/v1/buckets/{id}/objects/{key}` | Delete object |
| GET | `/api/obs/v1/buckets/{id}/objects/{key}/versions` | List object versions |

### Credentials

| Method | Path | Description |
|---|---|---|
| GET | `/api/obs/v1/buckets/{id}/credentials` | List credentials for bucket |
| POST | `/api/obs/v1/buckets/{id}/credentials` | Issue new credentials |
| DELETE | `/api/obs/v1/credentials/{id}` | Revoke a credential |

### Policies

| Method | Path | Description |
|---|---|---|
| GET | `/api/obs/v1/buckets/{id}/policies` | List bucket policies |
| POST | `/api/obs/v1/buckets/{id}/policies` | Create a policy |
| GET | `/api/obs/v1/policies/{id}` | Get policy details |
| DELETE | `/api/obs/v1/policies/{id}` | Delete a policy |

### Health & Metrics

| Method | Path | Description |
|---|---|---|
| GET | `/api/obs/health` | Health check |
| GET | `/api/obs/ready` | Readiness probe |
| GET | `/api/obs/v1/metrics` | Aggregate metrics |

## Solution Diagram

```
┌─────────────────────────────┐
│   Cloud Foundry / Kyma App  │
└─────────┬───────────────────┘
          │ REST API
          ▼
┌─────────────────────────────┐
│   Object Store Service      │
│  (bucket + object CRUD,     │
│   credential management)    │
└─────────┬───────────────────┘
          │ Secure Credentials
          ▼
┌────────────┬────────────┬────────┐
│  AWS S3    │ Azure Blob │  GCS   │
│  Buckets   │ Containers │ Buckets│
└────────────┴────────────┴────────┘
```

## Container

```bash
# Build
podman build -t ghcr.io/uimsolutions/uim-sap-obs:latest .

# Run
podman run --rm -p 8091:8091 ghcr.io/uimsolutions/uim-sap-obs:latest
```

## Kubernetes

```bash
kubectl apply -f k8s/
```

## License

Apache-2.0
