# SAP BTP, Kyma Runtime Service

A service similar to "SAP BTP, Kyma runtime" built with D, uim-framework, and vibe.d.

Provides a fully managed Kubernetes-based runtime with serverless functions,
containerized microservices, event-driven architecture, and consumption-based metrics.

## Features

| Feature | Description |
|---------|-------------|
| **Namespace Management** | Create isolated environments for organizing workloads |
| **Serverless Functions** | Deploy and invoke lightweight functions (Node.js, Python, D runtimes) |
| **Microservices** | Deploy and manage containerized microservices with scaling policies |
| **Event-Driven Architecture** | Publish events, create subscriptions, automatic fan-out delivery |
| **API Rules** | Expose services with configurable access strategies (JWT, OAuth2) |
| **Service Bindings** | Bind BTP service instances to workloads with credential injection |
| **Consumption Metrics** | Track resource usage, invocations, and events for billing |
| **Health / Readiness** | Kubernetes-compatible health and readiness probes |

## API Reference

Base path: `/api/kym`

### Health & Metrics

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/ready` | Readiness check |
| GET | `/v1/metrics` | Consumption-based metrics |

### Namespaces

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/namespaces` | List all namespaces |
| POST | `/v1/namespaces/{ns}` | Create namespace |
| PUT | `/v1/namespaces/{ns}` | Update namespace |
| GET | `/v1/namespaces/{ns}` | Get namespace details |
| DELETE | `/v1/namespaces/{ns}` | Delete namespace and all resources |

### Serverless Functions

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/namespaces/{ns}/functions` | List functions |
| POST | `/v1/namespaces/{ns}/functions/{name}` | Create function |
| PUT | `/v1/namespaces/{ns}/functions/{name}` | Update function |
| GET | `/v1/namespaces/{ns}/functions/{name}` | Get function details |
| DELETE | `/v1/namespaces/{ns}/functions/{name}` | Delete function |
| POST | `/v1/namespaces/{ns}/functions/{name}/invoke` | Invoke function |

### Microservices

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/namespaces/{ns}/microservices` | List microservices |
| POST | `/v1/namespaces/{ns}/microservices/{name}` | Deploy microservice |
| PUT | `/v1/namespaces/{ns}/microservices/{name}` | Update microservice |
| GET | `/v1/namespaces/{ns}/microservices/{name}` | Get microservice details |
| DELETE | `/v1/namespaces/{ns}/microservices/{name}` | Delete microservice |
| POST | `/v1/namespaces/{ns}/microservices/{name}/scale` | Scale microservice |

### Events

| Method | Path | Description |
|--------|------|-------------|
| POST | `/v1/namespaces/{ns}/events` | Publish event |

### Subscriptions

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/namespaces/{ns}/subscriptions` | List subscriptions |
| POST | `/v1/namespaces/{ns}/subscriptions` | Create subscription |
| GET | `/v1/namespaces/{ns}/subscriptions/{id}` | Get subscription |
| DELETE | `/v1/namespaces/{ns}/subscriptions/{id}` | Delete subscription |

### API Rules

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/namespaces/{ns}/api-rules` | List API rules |
| POST | `/v1/namespaces/{ns}/api-rules/{name}` | Create API rule |
| PUT | `/v1/namespaces/{ns}/api-rules/{name}` | Update API rule |
| GET | `/v1/namespaces/{ns}/api-rules/{name}` | Get API rule |
| DELETE | `/v1/namespaces/{ns}/api-rules/{name}` | Delete API rule |

### Service Bindings

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/namespaces/{ns}/service-bindings` | List service bindings |
| POST | `/v1/namespaces/{ns}/service-bindings/{name}` | Create service binding |
| GET | `/v1/namespaces/{ns}/service-bindings/{name}` | Get service binding |
| DELETE | `/v1/namespaces/{ns}/service-bindings/{name}` | Delete service binding |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KYM_HOST` | `0.0.0.0` | Bind address |
| `KYM_PORT` | `8088` | Listen port |
| `KYM_BASE_PATH` | `/api/kym` | API base path |
| `KYM_SERVICE_NAME` | `uim-kym` | Service name in responses |
| `KYM_SERVICE_VERSION` | `1.0.0` | Service version |
| `KYM_AUTH_TOKEN` | *(empty)* | Bearer token; enables auth when set |
| `KYM_MAX_NAMESPACES` | `100` | Max namespaces |
| `KYM_MAX_FUNCTIONS_PER_NS` | `500` | Max functions per namespace |
| `KYM_MAX_MICROSERVICES_PER_NS` | `200` | Max microservices per namespace |
| `KYM_MAX_SUBSCRIPTIONS_PER_NS` | `1000` | Max subscriptions per namespace |
| `KYM_DEFAULT_FUNCTION_TIMEOUT` | `30` | Default function timeout (seconds) |
| `KYM_DEFAULT_REPLICAS` | `1` | Default microservice replica count |

## Build & Run

```bash
# Build
make build

# Run locally
make run

# Container
make container-build
make container-run
```

## Kubernetes Deployment

```bash
make k8s-apply    # Deploy
make k8s-delete   # Tear down
```

## License

Apache-2.0
