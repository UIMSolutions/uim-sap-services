# UIM SAP Continuous Integration and Delivery Service

A cloud-based **Continuous Integration and Delivery (CI/CD)** service built with
**D (Dlang)**, **Vibe.D** and the **UIM Framework**. It mirrors the capabilities
of the SAP Continuous Integration and Delivery service.

## Features

| Capability | Description |
|---|---|
| **Predefined CI/CD Pipelines** | Configure predefined continuous integration and delivery pipelines for SAP development projects |
| **Git Repository Connections** | Connect the service to your Git repositories (GitHub, GitLab, Bitbucket, …) |
| **Credentials Management** | Create and store credentials for private Git repositories securely |
| **Pipeline Runs** | Run predefined pipelines that automatically build, test, and deploy code changes |
| **Build Monitoring** | Monitor the status of builds and view detailed stage-level logs |
| **Stage-based Execution** | Each build runs through configurable stages: build, test, deploy |
| **Multi-tenant** | Tenant-isolated data store for all entities |

## Quick Start

```bash
# Build
dub build

# Run locally
CID_PORT=8102 ./build/uim-sap-cid-service

# Podman
cd build && bash podman-run.sh

# Kubernetes
kubectl apply -f k8s/
```

## API

Base path: `/api/cicd`

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/health` | Health check |
| `GET` | `/ready` | Readiness probe |
| `GET` | `/` | Interactive dashboard |
| **Repositories** | | |
| `GET` | `/v1/tenants/:tid/repositories` | List repositories |
| `POST` | `/v1/tenants/:tid/repositories` | Connect a repository |
| `GET` | `/v1/tenants/:tid/repositories/:id` | Get repository details |
| `DELETE` | `/v1/tenants/:tid/repositories/:id` | Remove repository |
| **Credentials** | | |
| `GET` | `/v1/tenants/:tid/credentials` | List credentials |
| `POST` | `/v1/tenants/:tid/credentials` | Create credential |
| `DELETE` | `/v1/tenants/:tid/credentials/:id` | Delete credential |
| **Pipelines** | | |
| `GET` | `/v1/tenants/:tid/pipelines` | List pipelines |
| `POST` | `/v1/tenants/:tid/pipelines` | Create pipeline |
| `GET` | `/v1/tenants/:tid/pipelines/:id` | Get pipeline detail |
| `DELETE` | `/v1/tenants/:tid/pipelines/:id` | Delete pipeline |
| **Builds** | | |
| `GET` | `/v1/tenants/:tid/builds` | List builds |
| `POST` | `/v1/tenants/:tid/pipelines/:id/trigger` | Trigger a build |
| `GET` | `/v1/tenants/:tid/builds/:id` | Get build detail |
| `POST` | `/v1/tenants/:tid/builds/:id/abort` | Abort a running build |
| `GET` | `/v1/tenants/:tid/builds/:id/stages` | List build stages |
| `GET` | `/v1/tenants/:tid/builds/:id/logs` | List build logs |

## Configuration

| Variable | Default | Description |
|---|---|---|
| `CID_HOST` | `0.0.0.0` | Bind address |
| `CID_PORT` | `8102` | Listen port |
| `CID_BASE_PATH` | `/api/cicd` | API base path |
| `CID_SERVICE_NAME` | `uim-sap-cid` | Service name |
| `CID_SERVICE_VERSION` | `1.0.0` | Reported version |
| `CID_RUNTIME` | `cloud-foundry` | Runtime environment |
| `CID_AUTH_TOKEN` | *(empty)* | Bearer token for auth |

## License

Apache-2.0 — see [LICENSE](../LICENSE).
