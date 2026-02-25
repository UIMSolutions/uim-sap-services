#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8094/api/html5-repo}"
TENANT_ID="${TENANT_ID:-t1}"
SPACE_ID="${SPACE_ID:-space-a}"
APP_ID="${APP_ID:-smoke-dashboard}"
AUTH_TOKEN="${AUTH_TOKEN:-}"

RUNTIME_URL="$BASE_URL/runtime/$TENANT_ID/$SPACE_ID/$APP_ID/active/index.html"

log() {
  printf '[smoke] %s\n' "$1"
}

api_call() {
  local method="$1"
  local path="$2"
  local data="${3:-}"

  local url="$BASE_URL$path"
  local -a headers
  headers=(-H "X-Tenant-ID: $TENANT_ID" -H "X-Space-ID: $SPACE_ID")

  if [[ -n "$AUTH_TOKEN" ]]; then
    headers+=(-H "Authorization: Bearer $AUTH_TOKEN")
  fi

  if [[ -n "$data" ]]; then
    curl -sSf -X "$method" "$url" "${headers[@]}" -H "Content-Type: application/json" -d "$data"
  else
    curl -sSf -X "$method" "$url" "${headers[@]}"
  fi
}

runtime_get() {
  curl -sSf "$RUNTIME_URL"
}

b64() {
  printf '%s' "$1" | base64 | tr -d '\n'
}

V1_CONTENT='<!doctype html><html><body><h1>SMOKE_V1</h1></body></html>'
V2_CONTENT='<!doctype html><html><body><h1>SMOKE_V2</h1></body></html>'

V1_B64="$(b64 "$V1_CONTENT")"
V2_B64="$(b64 "$V2_CONTENT")"

UPLOAD_V1_PAYLOAD=$(cat <<JSON
{
  "visibility": "public",
  "activate": true,
  "files": [
    {
      "path": "index.html",
      "content_base64": "$V1_B64",
      "content_type": "text/html"
    }
  ]
}
JSON
)

UPLOAD_V2_PAYLOAD=$(cat <<JSON
{
  "visibility": "public",
  "activate": false,
  "files": [
    {
      "path": "index.html",
      "content_base64": "$V2_B64",
      "content_type": "text/html"
    }
  ]
}
JSON
)

log "Checking service health at $BASE_URL/health"
curl -sSf "$BASE_URL/health" >/dev/null

log "Uploading version 1.0.0 with activate=true"
api_call POST "/v1/apps/$APP_ID/versions/1.0.0" "$UPLOAD_V1_PAYLOAD" >/dev/null

log "Validating active runtime content is V1"
ACTIVE_CONTENT="$(runtime_get)"
if [[ "$ACTIVE_CONTENT" != *"SMOKE_V1"* ]]; then
  echo "Expected active content to contain SMOKE_V1"
  exit 1
fi

log "Uploading version 1.0.1 with activate=false"
api_call POST "/v1/apps/$APP_ID/versions/1.0.1" "$UPLOAD_V2_PAYLOAD" >/dev/null

log "Ensuring active runtime still serves V1 before activation"
ACTIVE_CONTENT="$(runtime_get)"
if [[ "$ACTIVE_CONTENT" != *"SMOKE_V1"* ]]; then
  echo "Expected active content to remain SMOKE_V1 before activation"
  exit 1
fi

log "Activating version 1.0.1"
api_call POST "/v1/apps/$APP_ID/versions/1.0.1/activate" >/dev/null

log "Validating active runtime content switched to V2"
ACTIVE_CONTENT="$(runtime_get)"
if [[ "$ACTIVE_CONTENT" != *"SMOKE_V2"* ]]; then
  echo "Expected active content to contain SMOKE_V2 after activation"
  exit 1
fi

log "Smoke test passed (upload, zero-downtime check, activate, runtime fetch)."
