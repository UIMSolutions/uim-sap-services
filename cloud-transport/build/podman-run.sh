#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-ctm:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-ctm}"
HOST_PORT="${HOST_PORT:-8100}"

echo "Building image: $IMAGE_TAG"
podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

echo "Starting container on port $HOST_PORT..."
podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8100 \
  -e CTM_HOST=0.0.0.0 \
  -e CTM_PORT=8100 \
  -e CTM_BASE_PATH=/api/cloud-transport \
  -e CTM_SERVICE_NAME=uim-sap-ctm \
  -e CTM_SERVICE_VERSION=1.0.0 \
  -e CTM_RUNTIME=cloud-foundry \
  "$IMAGE_TAG"
