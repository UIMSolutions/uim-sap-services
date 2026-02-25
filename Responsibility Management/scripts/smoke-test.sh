#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8095/api/rms}"
TENANT_ID="${TENANT_ID:-t1}"
SPACE_ID="${SPACE_ID:-workflow}"
AUTH_TOKEN="${AUTH_TOKEN:-}"
TEAM_NAME="${TEAM_NAME:-Smoke Invoice Team}"

log() {
  printf '[smoke-rms] %s\n' "$1"
}

with_headers() {
  local -a headers
  headers=(
    -H "X-Tenant-ID: $TENANT_ID"
    -H "X-Space-ID: $SPACE_ID"
  )

  if [[ -n "$AUTH_TOKEN" ]]; then
    headers+=(-H "Authorization: Bearer $AUTH_TOKEN")
  fi

  printf '%s\n' "${headers[@]}"
}

call_json() {
  local method="$1"
  local path="$2"
  local payload="${3:-}"

  local url="$BASE_URL$path"
  mapfile -t headers < <(with_headers)

  if [[ -n "$payload" ]]; then
    curl -sSf -X "$method" "$url" "${headers[@]}" -H "Content-Type: application/json" -d "$payload"
  else
    curl -sSf -X "$method" "$url" "${headers[@]}"
  fi
}

extract_json_field() {
  local json="$1"
  local field="$2"
  printf '%s' "$json" | tr -d '\n' | sed -n "s/.*\"$field\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p"
}

assert_contains() {
  local text="$1"
  local expected="$2"
  if [[ "$text" != *"$expected"* ]]; then
    echo "Expected response to contain: $expected"
    exit 1
  fi
}

log "Checking health"
curl -sSf "$BASE_URL/health" >/dev/null

log "Creating team"
TEAM_RESPONSE=$(call_json POST "/v1/teams" "{
  \"name\": \"$TEAM_NAME\",
  \"type_code\": \"DEFAULT\",
  \"category_code\": \"FINANCE\",
  \"members\": [
    {
      \"user_id\": \"alice\",
      \"display_name\": \"Alice\",
      \"is_owner\": true,
      \"notifications_enabled\": true,
      \"functions\": [\"APPROVER\"]
    },
    {
      \"user_id\": \"bob\",
      \"display_name\": \"Bob\",
      \"is_owner\": false,
      \"notifications_enabled\": true,
      \"functions\": [\"REVIEWER\"]
    }
  ]
}")
TEAM_ID=$(extract_json_field "$TEAM_RESPONSE" "id")
if [[ -z "$TEAM_ID" ]]; then
  echo "Could not extract team id from response"
  exit 1
fi

log "Creating determination rule"
RULE_RESPONSE=$(call_json POST "/v1/rules" "{
  \"name\": \"Smoke Overdue Approver Rule\",
  \"context_type\": \"invoice\",
  \"object_type\": \"document\",
  \"mode\": \"condition\",
  \"condition_field\": \"status\",
  \"condition_equals\": \"OVERDUE\",
  \"team_id\": \"$TEAM_ID\",
  \"function_code\": \"APPROVER\",
  \"priority\": 300,
  \"enabled\": true
}")
RULE_ID=$(extract_json_field "$RULE_RESPONSE" "id")
if [[ -z "$RULE_ID" ]]; then
  echo "Could not extract rule id from response"
  exit 1
fi

log "Running agent determination"
DET_RESPONSE=$(call_json POST "/v1/determine" "{
  \"context_type\": \"invoice\",
  \"object_type\": \"document\",
  \"document_id\": \"INV-SMOKE-1\",
  \"payload\": {\"status\": \"OVERDUE\"},
  \"notify\": true
}")
assert_contains "$DET_RESPONSE" "alice"
assert_contains "$DET_RESPONSE" "INV-SMOKE-1"

log "Checking determination logs"
LOGS_RESPONSE=$(call_json GET "/v1/logs?limit=5")
assert_contains "$LOGS_RESPONSE" "INV-SMOKE-1"

log "Checking export data"
EXPORT_RESPONSE=$(call_json GET "/v1/export")
assert_contains "$EXPORT_RESPONSE" "$TEAM_ID"
assert_contains "$EXPORT_RESPONSE" "$RULE_ID"

log "Smoke test passed (team, rule, determination, logs, export)."
