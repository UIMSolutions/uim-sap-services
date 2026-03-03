#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-docmgmt-integration:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-docmgmt-integration}"
HOST_PORT="${HOST_PORT:-8091}"

podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8091 \
  -e DMSI_HOST=0.0.0.0 \
  -e DMSI_PORT=8091 \
  -e DMSI_BASE_PATH=/api/docmgmt-integration \
  -e DMSI_MULTITENANCY_ENABLED=true \
  -e DMSI_ENCRYPTION_ENABLED=false \
  -e DMSI_VERSIONING_ENABLED=true \
  -v dmsi-data:/data/documents:Z \
  "$IMAGE_TAG"
