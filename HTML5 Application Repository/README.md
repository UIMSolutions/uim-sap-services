# UIM HTML5 Application Repository Service

SAP HTML5 Application Repository style service for SAP BTP scenarios, built with D, `vibe.d`, and `uim-framework`.

This service provides central storage and runtime delivery of HTML5 application static content with:

- zero down-time activation by switching active version pointers
- versioned application content lifecycle
- private/public visibility and cross-space public sharing
- multitenancy (`tenant_id` + `space_id`) support
- runtime cache for efficient static content serving
- Podman and Kubernetes deployment assets

## Build and Run

```bash
cd "HTML5 Application Repository"
dub build
./build/uim-sap-html5-app-repo-service
```

### Environment variables

- `HTML5_REPO_HOST` (default `0.0.0.0`)
- `HTML5_REPO_PORT` (default `8094`)
- `HTML5_REPO_BASE_PATH` (default `/api/html5-repo`)
- `HTML5_REPO_SERVICE_NAME` (default `uim-sap-html5-app-repo`)
- `HTML5_REPO_SERVICE_VERSION` (default `1.0.0`)
- `HTML5_REPO_DATA_DIR` (default `/tmp/uim-html5-repo-data`)
- `HTML5_REPO_DEFAULT_TENANT` (default `provider`)
- `HTML5_REPO_DEFAULT_SPACE` (default `dev`)
- `HTML5_REPO_CACHE_TTL_SECONDS` (default `120`)
- `HTML5_REPO_ALLOW_PUBLIC_CROSS_SPACE` (default `true`)
- `HTML5_REPO_MAX_UPLOAD_BYTES` (default `52428800`)
- `HTML5_REPO_AUTH_TOKEN` (optional bearer token for `/v1` management APIs)

## Podman

```bash
cd "HTML5 Application Repository"
podman build -t uim-sap-html5-repo:local -f Dockerfile .
podman run --rm \
  -p 8094:8094 \
  -e HTML5_REPO_AUTH_TOKEN=secret123 \
  -v $(pwd)/build/repo-data:/var/lib/uim-html5-repo:Z \
  --name uim-sap-html5-repo \
  uim-sap-html5-repo:local
```

## Kubernetes

```bash
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## API

Base path: `/api/html5-repo`

### Health

- `GET /health`
- `GET /ready`

### Management APIs (`/v1`)

Headers:

- `X-Tenant-ID` (optional, defaults by config)
- `X-Space-ID` (optional, defaults by config)
- `Authorization: Bearer <token>` (required only if `HTML5_REPO_AUTH_TOKEN` is configured)

Endpoints:

- `GET /v1/apps`
- `GET /v1/apps/{appId}/versions`
- `GET /v1/apps/{appId}/active`
- `GET /v1/apps/{appId}/versions/{versionId}/files`
- `POST /v1/apps/{appId}/versions/{versionId}`
- `POST /v1/apps/{appId}/versions/{versionId}/activate`
- `DELETE /v1/apps/{appId}/versions/{versionId}`

### Runtime APIs

- `GET /runtime/{tenantId}/{spaceId}/{appId}/active/{assetPath...}`
- `GET /runtime/{tenantId}/{spaceId}/{appId}/versions/{versionId}/{assetPath...}`

Optional runtime consumer headers:

- `X-Consumer-Tenant-ID`
- `X-Consumer-Space-ID`

## Example use-cases

### 1) Upload version and activate immediately (zero down-time)

```bash
INDEX_B64=$(printf '<!doctype html><html><body><h1>Hello Repo</h1></body></html>' | base64 -w0)

curl -X POST "http://localhost:8094/api/html5-repo/v1/apps/sales-dashboard/versions/1.0.0" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-ID: t1" \
  -H "X-Space-ID: space-a" \
  -H "Authorization: Bearer secret123" \
  -d '{
    "visibility": "public",
    "activate": true,
    "files": [
      {
        "path": "index.html",
        "content_base64": "'"$INDEX_B64"'",
        "content_type": "text/html"
      }
    ]
  }'
```

### 2) Explore versions

```bash
curl "http://localhost:8094/api/html5-repo/v1/apps/sales-dashboard/versions" \
  -H "X-Tenant-ID: t1" \
  -H "X-Space-ID: space-a" \
  -H "Authorization: Bearer secret123"
```

### 3) Switch active version without router restart

```bash
curl -X POST "http://localhost:8094/api/html5-repo/v1/apps/sales-dashboard/versions/1.0.1/activate" \
  -H "X-Tenant-ID: t1" \
  -H "X-Space-ID: space-a" \
  -H "Authorization: Bearer secret123"
```

### 4) Runtime consumption by active version

```bash
curl "http://localhost:8094/api/html5-repo/runtime/t1/space-a/sales-dashboard/active/index.html"
```

### 5) Cross-space runtime consumption of public app

```bash
curl "http://localhost:8094/api/html5-repo/runtime/t1/space-a/sales-dashboard/active/index.html" \
  -H "X-Consumer-Tenant-ID: t1" \
  -H "X-Consumer-Space-ID: space-b"
```

If the active version is private, cross-space access is rejected.
