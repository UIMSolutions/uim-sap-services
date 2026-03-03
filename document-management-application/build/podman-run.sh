#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-document-management:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-document-management}"
HOST_PORT="${HOST_PORT:-8090}"

podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8090 \
  -e DMS_HOST=0.0.0.0 \
  -e DMS_PORT=8090 \
  -e DMS_BASE_PATH=/api/docmgmt \
  -e DMS_ENCRYPTION_ENABLED=false \
  -e DMS_VERSIONING_ENABLED=true \
  -v dms-data:/data/documents:Z \
  "$IMAGE_TAG"
