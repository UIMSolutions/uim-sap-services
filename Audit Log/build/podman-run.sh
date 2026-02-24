#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-audit-log:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-audit-log}"
HOST_PORT="${HOST_PORT:-8090}"

podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8090 \
  -e AUDITLOG_HOST=0.0.0.0 \
  -e AUDITLOG_PORT=8090 \
  -e AUDITLOG_BASE_PATH=/api/auditlog \
  -e AUDITLOG_DEFAULT_RETENTION_DAYS=90 \
  "$IMAGE_TAG"
