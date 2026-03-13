# Project and Resource Management Service

`project-resource-management` is a D + vibe.d + UIM-framework microservice that provides the core use cases of a SaaS-style project and resource management solution.

## Implemented capabilities

- Main project schedule with work package integration from SAP and third-party sources.
- Shared execution board items across companies:
  - tasks
  - deliverables
  - issues
  - punch lists
- Collaboration onboarding with partner invitation using a global business partner repository.
- Repeatable delivery process templates that can be associated with projects.
- Resource discovery by skills/experience and real-time capacity snapshots.
- Central resource request management across multiple projects.

## Run locally

```bash
cd project-resource-management
dub run
```

Service defaults:

- Host: `0.0.0.0`
- Port: `8096`
- Base path: `/api/prm`

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

## API outline

Base: `/api/prm/v1`

- Global business partner repository:
  - `GET /business-partners`
  - `POST /business-partners`
- Tenant-scoped:
  - `GET|POST /tenants/{tenantId}/projects`
  - `GET|PUT|DELETE /tenants/{tenantId}/projects/{projectId}`
  - `GET|POST /tenants/{tenantId}/projects/{projectId}/work-packages`
  - `GET|POST /tenants/{tenantId}/projects/{projectId}/board-items`
  - `GET /tenants/{tenantId}/projects/{projectId}/board`
  - `GET|POST /tenants/{tenantId}/partners`
  - `POST /tenants/{tenantId}/projects/{projectId}/partner-invitations`
  - `GET|POST /tenants/{tenantId}/delivery-processes`
  - `GET|POST /tenants/{tenantId}/resources`
  - `POST /tenants/{tenantId}/resources/search`
  - `GET /tenants/{tenantId}/resources/capacity`
  - `GET|POST /tenants/{tenantId}/resource-requests`
  - `POST /tenants/{tenantId}/projects/{projectId}/resource-match`
