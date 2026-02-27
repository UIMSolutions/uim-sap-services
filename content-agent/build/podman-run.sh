#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-content-agent:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-content-agent}"
HOST_PORT="${HOST_PORT:-8096}"

podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8096 \
  -e CAG_HOST=0.0.0.0 \
  -e CAG_PORT=8096 \
  -e CAG_BASE_PATH=/api/content-agent \
  -e CAG_RUNTIME=cloud-foundry \
  "$IMAGE_TAG"
