# SAP Personalized Recommendation — UIM Service

AI-powered personalized recommendation service for SAP BTP, built with D, the UIM framework, and vibe.d.

Uses machine learning techniques to deliver highly personalized recommendations based on browsing history and item descriptions across a wide range of business scenarios.

## Features

- **Next-Item Recommendations** — personalized suggestions based on user interaction history and category/tag affinity
- **Similar-Item Recommendations** — alternative items matching the currently viewed item via attribute, category, and tag overlap
- **Smart Search** — personalised search results combining text queries with user context and interaction history
- **User-Affinity Recommendations** — item-attribute preferences (categories, tags, attributes) derived from past interactions
- **Item Catalog** — manage items with rich attributes, tags, categories, and pricing
- **User Management** — register users, track segments and preferences
- **Interaction Tracking** — record views, clicks, purchases, bookmarks, ratings, and more
- **Model Management** — create, train, and evaluate recommendation models
- **Scenario Management** — tie models to business scenarios (ecommerce, media, news, travel, education)
- **Training Jobs** — track model training lifecycle (queued → running → completed)
- **Multitenancy** — tenant-scoped data isolation with configurable limits

## Endpoints

### Health
| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/ready` | Readiness check |

### Item Catalog
| Method | Path | Description |
|--------|------|-------------|
| GET/POST | `/v1/tenants/{tid}/items` | List / add items |
| GET/PUT/DELETE | `/v1/tenants/{tid}/items/{id}` | Get / update / delete item |
| GET | `/v1/tenants/{tid}/items/{id}/interactions` | Item interaction history |

### Users
| Method | Path | Description |
|--------|------|-------------|
| GET/POST | `/v1/tenants/{tid}/users` | List / register users |
| GET/PUT/DELETE | `/v1/tenants/{tid}/users/{id}` | Get / update / delete user |
| GET | `/v1/tenants/{tid}/users/{id}/interactions` | User interaction history |

### Interactions
| Method | Path | Description |
|--------|------|-------------|
| POST | `/v1/tenants/{tid}/interactions` | Record an interaction |

### Models
| Method | Path | Description |
|--------|------|-------------|
| GET/POST | `/v1/tenants/{tid}/models` | List / create models |
| GET/DELETE | `/v1/tenants/{tid}/models/{id}` | Get / delete model |
| POST | `/v1/tenants/{tid}/models/{id}/train` | Train model |
| GET | `/v1/tenants/{tid}/models/{id}/jobs` | List training jobs |

### Scenarios
| Method | Path | Description |
|--------|------|-------------|
| GET/POST | `/v1/tenants/{tid}/scenarios` | List / create scenarios |
| GET/DELETE | `/v1/tenants/{tid}/scenarios/{id}` | Get / delete scenario |

### Recommendations
| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/tenants/{tid}/recommend/next-item?userId=&modelId=&limit=` | Next-item recommendations |
| GET | `/v1/tenants/{tid}/recommend/similar-item?itemId=&modelId=&limit=` | Similar-item recommendations |
| GET | `/v1/tenants/{tid}/recommend/smart-search?userId=&q=&modelId=&limit=` | Smart search results |
| GET | `/v1/tenants/{tid}/recommend/user-affinity?userId=&modelId=&limit=` | User affinity preferences |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PRE_HOST` | `0.0.0.0` | Bind host |
| `PRE_PORT` | `8093` | Bind port |
| `PRE_BASE_PATH` | `/api/pre` | Base path prefix |
| `PRE_SERVICE_NAME` | `uim-pre` | Service name |
| `PRE_AUTH_TOKEN` | *(none)* | Bearer token (enables auth when set) |
| `PRE_MAX_ITEMS_PER_TENANT` | `500000` | Max catalog items per tenant |
| `PRE_MAX_USERS_PER_TENANT` | `1000000` | Max users per tenant |
| `PRE_MAX_INTERACTIONS_PER_USER` | `10000` | Max interactions per user |
| `PRE_MAX_MODELS_PER_TENANT` | `50` | Max models per tenant |
| `PRE_MAX_SCENARIOS_PER_TENANT` | `100` | Max scenarios per tenant |
| `PRE_DEFAULT_LIMIT` | `10` | Default recommendation count |
| `PRE_MAX_LIMIT` | `100` | Maximum recommendation count |
| `PRE_DEFAULT_TENANT_ID` | `default` | Default tenant ID |
| `PRE_MULTITENANCY` | `true` | Enable multitenancy |

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

## Kubernetes

```bash
kubectl apply -f k8s/
```

## License

Apache-2.0
