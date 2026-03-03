# UIM SAP Feature Flags Service

A **SAP Feature Flags**-compatible service built with **D**, **vibe.d**, and the
**UIM Framework**.  It lets you enable or disable features at runtime without
redeploying or restarting applications.

## Features

| Capability | Description |
|---|---|
| **Boolean flags** | Switch functionality on/off — evaluate to `true` or `false` |
| **String flags** | Multiple named variations (A/B/C…) with text values |
| **Direct delivery** | Target specific identifiers (users, tenants, …) |
| **Percentage delivery** | Distribute variations by weight across all callers |
| **Toggle** | Quick on/off switch endpoint |
| **Export / Import** | Move all flag definitions between service instances |
| **Multitenancy** | Every operation is scoped to a `tenantId` path segment |
| **Dashboard** | Aggregated metrics per tenant |

## Quick Start

### Local (DUB)

```bash
cd feature-flags
dub run
# → http://localhost:8094/api/ff/health
```

### Podman

```bash
cd feature-flags
./build/podman-run.sh
# → http://localhost:8094/api/ff/health
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.example.yaml   # change the token first!
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `FF_HOST` | `0.0.0.0` | Listen address |
| `FF_PORT` | `8094` | Listen port |
| `FF_BASE_PATH` | `/api/ff` | URL prefix for all endpoints |
| `FF_SERVICE_NAME` | `uim-sap-ff` | Reported in `/health` |
| `FF_SERVICE_VERSION` | `1.0.0` | Reported in `/health` |
| `FF_AUTH_TOKEN` | *(empty)* | If set, every request must carry `Authorization: Bearer <token>` |

## API Reference

All business endpoints are prefixed with
`{basePath}/v1/tenants/{tenantId}/…`

### Platform

| Method | Path | Description |
|---|---|---|
| `GET` | `/health` | Health check |
| `GET` | `/ready` | Readiness probe |

### Flags CRUD

| Method | Path | Description |
|---|---|---|
| `POST` | `/v1/tenants/{tenantId}/flags` | Create a flag |
| `GET` | `/v1/tenants/{tenantId}/flags` | List all flags |
| `GET` | `/v1/tenants/{tenantId}/flags/{flagName}` | Get flag details |
| `PUT` | `/v1/tenants/{tenantId}/flags/{flagName}` | Update a flag |
| `DELETE` | `/v1/tenants/{tenantId}/flags/{flagName}` | Delete a flag |
| `POST` | `/v1/tenants/{tenantId}/flags/{flagName}/toggle` | Toggle enabled state |

### Evaluation

| Method | Path | Description |
|---|---|---|
| `GET` | `/v1/tenants/{tenantId}/flags/{flagName}/evaluate?identifier=…` | Evaluate flag |

The optional `identifier` query parameter enables direct and percentage delivery
strategies.

### Export / Import

| Method | Path | Description |
|---|---|---|
| `GET` | `/v1/tenants/{tenantId}/export` | Export all flags as JSON |
| `POST` | `/v1/tenants/{tenantId}/import` | Import flags (replaces existing) |

### Dashboard

| Method | Path | Description |
|---|---|---|
| `GET` | `/v1/tenants/{tenantId}/dashboard` | Aggregated flag metrics |

## Usage Examples

### Create a Boolean Flag

```bash
curl -X POST http://localhost:8094/api/ff/v1/tenants/myapp/flags \
  -H 'Content-Type: application/json' \
  -d '{
    "flag_name": "dark-mode",
    "flag_type": "boolean",
    "enabled": false,
    "description": "Enable dark mode UI"
  }'
```

### Toggle a Flag On

```bash
curl -X POST http://localhost:8094/api/ff/v1/tenants/myapp/flags/dark-mode/toggle
```

### Evaluate a Boolean Flag

```bash
curl http://localhost:8094/api/ff/v1/tenants/myapp/flags/dark-mode/evaluate
# → { "evaluation": { "boolean_value": true, "strategy": "default" } }
```

### Create a String Flag with Variations

```bash
curl -X POST http://localhost:8094/api/ff/v1/tenants/myapp/flags \
  -H 'Content-Type: application/json' \
  -d '{
    "flag_name": "checkout-flow",
    "flag_type": "string",
    "description": "A/B test checkout page",
    "variations": [
      { "name": "control", "value": "classic-checkout", "weight": 70 },
      { "name": "experiment", "value": "new-checkout", "weight": 30 }
    ],
    "percentage_rule": {
      "entries": [
        { "variation_id": "<control-id>", "weight": 70 },
        { "variation_id": "<experiment-id>", "weight": 30 }
      ]
    }
  }'
```

### Direct Delivery — Target Specific Identifiers

```bash
curl -X PUT http://localhost:8094/api/ff/v1/tenants/myapp/flags/checkout-flow \
  -H 'Content-Type: application/json' \
  -d '{
    "direct_rules": [{
      "identifiers": ["beta-user-1", "beta-user-2"],
      "variation_id": "<experiment-variation-id>"
    }]
  }'
```

### Percentage Delivery Evaluation

```bash
curl "http://localhost:8094/api/ff/v1/tenants/myapp/flags/checkout-flow/evaluate?identifier=tenant-42"
# → { "evaluation": { "variation_value": "new-checkout", "strategy": "percentage" } }
```

### Export Flags

```bash
curl http://localhost:8094/api/ff/v1/tenants/myapp/export > flags-backup.json
```

### Import Flags into Another Tenant

```bash
curl -X POST http://localhost:8094/api/ff/v1/tenants/staging/import \
  -H 'Content-Type: application/json' \
  -d @flags-backup.json
```

## Evaluation Strategy Priority

When evaluating a flag, the service applies rules in this order:

1. **Inactive flag** — Boolean → `false`, String → default variation
2. **Direct delivery** — identifier matches a direct rule → return the rule's value
3. **Percentage delivery** — identifier hashed to a bucket → weighted variation
4. **Default** — Boolean → `enabled` field, String → `default_variation_id` or first variation

## Architecture

```
feature-flags/
├── source/
│   ├── app.d                                # Entry point
│   └── uim/sap/featureflags/
│       ├── package.d                        # Barrel imports
│       ├── config.d                         # FFConfig
│       ├── server.d                         # FFServer (vibe.d HTTP)
│       ├── service.d                        # FFService (business logic)
│       ├── store.d                          # FFStore (in-memory, mutex)
│       ├── models/
│       │   ├── flag.d                       # FFFlag struct
│       │   ├── variation.d                  # FFVariation struct
│       │   ├── directrule.d                 # FFDirectRule struct
│       │   ├── percentagerule.d             # FFPercentageRule/Entry
│       │   ├── evaluation.d                 # FFEvaluation result
│       │   └── exportdata.d                 # FFExportData container
│       ├── exceptions/                      # FF*Exception hierarchy
│       └── helpers/
│           └── helper.d                     # percentageBucket()
├── Dockerfile                               # Multi-stage Podman/Docker build
├── k8s/                                     # Kubernetes manifests
├── docs/uml/                                # PlantUML diagrams
└── build/podman-run.sh                      # One-command Podman launch
```

## License

Apache-2.0 — Copyright © 2018-2026, Ozan Nurettin Süel
