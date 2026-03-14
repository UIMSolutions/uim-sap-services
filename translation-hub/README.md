# Translation Hub (D + vibe.d)

Kubernetes- and Podman-compatible application inspired by SAP Translation Hub capabilities.

This service provides:
- Software translation APIs with multiple providers (`sap-nmt`, `llm`, `mltr`, `company-mltr`)
- Document translation APIs (sync and async-style workflow)
- In-memory translation project workflow management (file/git/ABAP-like projects)
- In-memory language data integration (domain/company translation assets)
- Quality index estimation (0-100)
- Minimal UI landing page and API discovery endpoint

## Feature Mapping

- Translate software and UI texts: `POST /api/v1/software/translate`
- Translate ABAP extensions and BTP apps (workflow representation): `POST /api/v1/projects`
- AI-powered document MT: `POST /api/v1/document/translate/sync`
- Document translation async flow: `POST /api/v1/document/translate/async` + `GET /api/v1/document/jobs/status`
- Integrate language data: `POST /api/v1/language-data`
- Translation quality score: `POST /api/v1/quality/estimate`
- API consumption: all endpoints under `/api/v1/*`

## Project Layout

- `source/app.d`: HTTP routes and minimal UI
- `source/config.d`: environment-based configuration
- `source/models.d`: request/response and domain models
- `source/providers.d`: provider interface and provider implementations
- `source/services.d`: business logic and in-memory stores
- `k8s/deployment.yaml`: Kubernetes deployment
- `k8s/service.yaml`: Kubernetes service
- `Dockerfile` / `Containerfile`: Docker/Podman image build

## Prerequisites

- D compiler + DUB (tested with `dmd`)
- Optional: Docker or Podman
- Optional: Kubernetes cluster with `kubectl`

## Local Run

```bash
dub run
```

Service starts on `0.0.0.0:8080` by default.

Health check:

```bash
curl -s http://localhost:8080/health | jq
```

## API Examples

Software translation:

```bash
curl -s http://localhost:8080/api/v1/software/translate \
  -H 'content-type: application/json' \
  -d '{
    "sourceLanguage":"en",
    "targetLanguage":"de",
    "provider":"sap-nmt",
    "domain":"sap",
    "texts":["Create Sales Order","Approve Invoice"]
  }' | jq
```

Quality estimate:

```bash
curl -s http://localhost:8080/api/v1/quality/estimate \
  -H 'content-type: application/json' \
  -d '{
    "targetLanguage":"de",
    "provider":"company-mltr",
    "texts":["Business Partner", "General Ledger"]
  }' | jq
```

Document translation (sync):

```bash
curl -s http://localhost:8080/api/v1/document/translate/sync \
  -H 'content-type: application/json' \
  -d '{
    "sourceLanguage":"en",
    "targetLanguage":"fr",
    "fileName":"guide.txt",
    "provider":"llm",
    "content":"This document explains the release workflow."
  }' | jq
```

Document translation (async-style):

```bash
JOB_ID=$(curl -s http://localhost:8080/api/v1/document/translate/async \
  -H 'content-type: application/json' \
  -d '{
    "sourceLanguage":"en",
    "targetLanguage":"es",
    "fileName":"faq.txt",
    "provider":"sap-nmt",
    "content":"How do I reset my password?"
  }' | jq -r .jobId)

curl -s "http://localhost:8080/api/v1/document/jobs/status?jobId=${JOB_ID}" | jq
```

Create software translation project:

```bash
curl -s http://localhost:8080/api/v1/projects \
  -H 'content-type: application/json' \
  -d '{
    "name":"BTP Extension i18n",
    "kind":"git",
    "sourceLanguage":"en",
    "targetLanguages":["de","fr","ja"]
  }' | jq
```

Integrate language data:

```bash
curl -s http://localhost:8080/api/v1/language-data \
  -H 'content-type: application/json' \
  -d '{
    "name":"Finance Glossary",
    "domain":"finance",
    "sourceLanguage":"en",
    "targetLanguage":"de",
    "segments":["General Ledger","Asset Accounting","Cost Center"]
  }' | jq
```

## Podman

Build and run:

```bash
podman build -t translation-hub:local -f Containerfile .
podman run --rm -p 8080:8080 -e PORT=8080 translation-hub:local
```

## Docker

Build and run:

```bash
docker build -t translation-hub:local .
docker run --rm -p 8080:8080 -e PORT=8080 translation-hub:local
```

## Kubernetes

1. Build image and load it into your cluster runtime (or push to your registry).
2. Update `k8s/deployment.yaml` image if needed.
3. Apply manifests:

```bash
kubectl apply -f k8s/
kubectl get pods -l app=translation-hub
kubectl get svc translation-hub
```

Port-forward for local access:

```bash
kubectl port-forward svc/translation-hub 8080:80
```

## Environment Variables

- `PORT` (default `8080`)
- `BIND_ADDRESS` (default `0.0.0.0`)
- `SERVICE_NAME` (default `translation-hub`)
- `SUPPORTED_LANGUAGES` CSV list for `/api/v1/providers`

## Notes

- This is a reference implementation, with in-memory stores and placeholder translation provider behavior.
- Provider outputs are intentionally prefixed to show routing and provider selection.
- Async document translation endpoint models an async contract; for production, replace with queue/workers and persistent storage.
