# UIM SAP Solution Lifecycle Management Service

A Dlang/Vibe.D/UIM-Framework microservice replicating SAP Solution Lifecycle Management for SAP BTP.

## Features

- **Deploy Solutions** – Provision a Solution by deploying it using a Multitarget Application (MTA) archive as the Solution carrier.
- **Update Solutions** – Update your Solution to enhance it with new capabilities or technical improvements by deploying a new MTA version.
- **Monitor Solutions** – Monitor the state of individual components, licenses, and subscribers of a given Solution via the Solutions view.
- **Delete Solutions** – Remove a Solution. Note that various Solution components interconnected with external resources are not removed.
- **Multitenant Subscriptions** – Subscribe to a multitenant Solution provided by another subaccount, given an entitlement from the Solution provider.
- **Deployment History** – Full operation history for deploy, update, and delete actions.
- **Component Monitoring** – Track the state, resource usage, and endpoints of individual Solution components.
- **License Tracking** – View license plans, quotas, and status per Solution.
- **Operation Logs** – Full audit log per Solution for monitoring and troubleshooting.
- **Multi-Tenancy** – All resources scoped to a tenant ID.
- **Dashboard UI** – Interactive web dashboard for all operations.

## API Base Path

```
/api/solution-lifecycle
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Service health |
| GET | `/ready` | Readiness probe |
| GET | `/` | Dashboard UI |
| **Solutions** | | |
| GET | `/v1/tenants/:t/solutions` | List all solutions |
| POST | `/v1/tenants/:t/solutions` | Deploy a new solution |
| GET | `/v1/tenants/:t/solutions/:id` | Get solution detail |
| PUT | `/v1/tenants/:t/solutions/:id` | Update solution (new MTA version) |
| DELETE | `/v1/tenants/:t/solutions/:id` | Delete solution |
| **Components** | | |
| GET | `/v1/tenants/:t/solutions/:id/components` | List solution components |
| GET | `/v1/tenants/:t/solutions/:id/components/:cid` | Get component detail |
| **Deployments** | | |
| GET | `/v1/tenants/:t/deployments` | List all tenant deployments |
| GET | `/v1/tenants/:t/solutions/:id/deployments` | List deployments for a solution |
| **Subscriptions** | | |
| GET | `/v1/tenants/:t/subscriptions` | List all tenant subscriptions |
| GET | `/v1/tenants/:t/solutions/:id/subscriptions` | List subscriptions for a solution |
| POST | `/v1/tenants/:t/solutions/:id/subscriptions` | Subscribe to a multitenant solution |
| POST | `/v1/tenants/:t/solutions/:id/subscriptions/:subId/unsubscribe` | Unsubscribe |
| **Licenses** | | |
| GET | `/v1/tenants/:t/solutions/:id/licenses` | List licenses for a solution |
| **Logs** | | |
| GET | `/v1/tenants/:t/solutions/:id/logs` | List operation logs for a solution |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SLM_HOST` | `0.0.0.0` | Bind address |
| `SLM_PORT` | `8120` | Listening port |
| `SLM_BASE_PATH` | `/api/solution-lifecycle` | Base URL path |
| `SLM_SERVICE_NAME` | `uim-sap-slm` | Service name |
| `SLM_SERVICE_VERSION` | `1.0.0` | Service version |
| `SLM_RUNTIME` | `cloud-foundry` | Runtime environment |
| `SLM_AUTH_TOKEN` | *(empty)* | Bearer token (optional) |

## Build

```bash
dub build --root=solution-lifecycle
```

## Run

```bash
./solution-lifecycle/build/uim-slm-service
```

## Docker / Podman

```bash
# Build the image
podman build -t uim-sap-slm:local solution-lifecycle/

# Run the container
podman run --rm -p 8120:8120 uim-sap-slm:local
```

Or use the helper script:

```bash
cd solution-lifecycle && bash build/podman-run.sh
```

## Kubernetes

```bash
kubectl apply -f solution-lifecycle/k8s/configmap.yaml
kubectl apply -f solution-lifecycle/k8s/secret.example.yaml   # edit first!
kubectl apply -f solution-lifecycle/k8s/deployment.yaml
kubectl apply -f solution-lifecycle/k8s/service.yaml
```

## Deploy a Solution (Example)

```bash
curl -X POST http://localhost:8120/api/solution-lifecycle/v1/tenants/acme/solutions \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "My Business App",
    "mta_id": "com.example.myapp",
    "mta_version": "2.1.0",
    "mta_archive_ref": "s3://builds/myapp-2.1.0.mtar",
    "multitenant": true,
    "components": [
      { "name": "backend", "component_type": "app", "memory_mb": 512, "instances": 2 },
      { "name": "frontend", "component_type": "app", "memory_mb": 256, "instances": 1 },
      { "name": "hdi-container", "component_type": "service-instance" }
    ]
  }'
```

## Subscribe to a Multitenant Solution

```bash
curl -X POST http://localhost:8120/api/solution-lifecycle/v1/tenants/acme/solutions/sol-1/subscriptions \
  -H 'Content-Type: application/json' \
  -d '{ "consumer_subaccount_id": "consumer-sub-123" }'
```

## License

Apache-2.0
