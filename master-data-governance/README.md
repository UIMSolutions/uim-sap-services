# UIM Master Data Governance Service (MDG)

Kubernetes-compatible Master Data Governance style service built with D, `vibe.d`, and `uim-framework`.

## Features

- Manage Business Partner master data in a workflow-driven central governance flow
- Create and maintain business partners including contact persons and relationships
- Process multiple business partners simultaneously in batch mode
- Reference/ingestion support from external data providers via API and file-style payload ingestion
- Consolidate master data into a single view by duplicate detection and merge-to-best-record workflows
- Evaluate data quality with collaboratively managed validation rules used across governance and consolidation

## Build and Run

```bash
cd mdg
dub build
./build/uim-sap-mdg-service
```

Environment variables:

- `MDG_HOST` (default `0.0.0.0`)
- `MDG_PORT` (default `8087`)
- `MDG_BASE_PATH` (default `/api/mdg`)
- `MDG_SERVICE_NAME` (default `uim-sap-mdg`)
- `MDG_SERVICE_VERSION` (default `1.0.0`)
- `MDG_DEFAULT_APPROVER` (default `mdg-approver`)
- `MDG_AUTH_TOKEN` (optional bearer token)

## Podman Container

```bash
cd mdg
podman build -t uim-sap-mdg:local -f Dockerfile .
podman run --rm -p 8087:8087 --name uim-sap-mdg uim-sap-mdg:local
```

## REST API

Base path: `/api/mdg`

- `GET /health`
- `GET /ready`
- `GET /v1/tenants/{tenant_id}/business-partners`
- `POST /v1/tenants/{tenant_id}/business-partners`
- `POST /v1/tenants/{tenant_id}/business-partners/batch`
- `PATCH /v1/tenants/{tenant_id}/business-partners/{bp_id}`
- `POST /v1/tenants/{tenant_id}/consolidation/ingest`
- `GET /v1/tenants/{tenant_id}/consolidation/duplicates`
- `POST /v1/tenants/{tenant_id}/consolidation/merge`
- `GET /v1/tenants/{tenant_id}/quality-rules`
- `PUT /v1/tenants/{tenant_id}/quality-rules/{rule_id}`
- `POST /v1/tenants/{tenant_id}/quality/evaluate`

### Example: create BP in governance workflow

```bash
curl -X POST "http://localhost:8087/api/mdg/v1/tenants/acme/business-partners" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Acme Supplier GmbH",
    "country": "DE",
    "email": "masterdata@acme.example",
    "contact_persons": [{"name": "Alex", "role": "Purchasing"}],
    "relationships": [{"type": "supplier-of", "target": "ACME-GROUP"}]
  }'
```

### Example: evaluate data quality

```bash
curl -X POST "http://localhost:8087/api/mdg/v1/tenants/acme/quality/evaluate"
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## UML Documentation (PlantUML)

Separate UML descriptions are available in `docs/uml`:

- `docs/uml/component-architecture.puml` - high-level service components and interactions
- `docs/uml/class-model.puml` - core classes, models, and dependencies
- `docs/uml/sequence-governance-workflow.puml` - create/update business partner workflow
- `docs/uml/sequence-consolidation-quality.puml` - duplicate detection/merge and quality evaluation

Render diagrams from this folder:

```bash
make uml-check # fail if no .puml files exist
make uml      # render PNG files
make uml-svg  # render SVG files
make uml-clean
```

Requirements: `plantuml` (and Java runtime available in PATH).

### CI example (GitHub Actions)

```yaml
name: uml-docs

on:
  push:
    paths:
      - 'Master Data Governance/docs/uml/**'
      - 'Master Data Governance/Makefile'

jobs:
  render-uml:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '21'
      - run: sudo apt-get update && sudo apt-get install -y plantuml make
      - run: cd "Master Data Governance" && make uml-check && make uml-svg
```

### CI example (GitLab)

```yaml
uml_docs:
  image: eclipse-temurin:21-jdk
  script:
    - apt-get update && apt-get install -y plantuml make
    - cd "Master Data Governance"
    - make uml-check
    - make uml-svg
  rules:
    - changes:
        - Master Data Governance/docs/uml/**/*
        - Master Data Governance/Makefile
```
