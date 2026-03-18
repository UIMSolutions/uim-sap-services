#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-slm:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-slm}"
HOST_PORT="${HOST_PORT:-8120}"

echo "Building image: $IMAGE_TAG"
podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

echo "Starting container on port $HOST_PORT..."
podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8120 \
  -e SLM_HOST=0.0.0.0 \
  -e SLM_PORT=8120 \
  -e SLM_BASE_PATH=/api/solution-lifecycle \
  -e SLM_SERVICE_NAME=uim-sap-slm \
  -e SLM_SERVICE_VERSION=1.0.0 \
  -e SLM_RUNTIME=cloud-foundry \
  "$IMAGE_TAG"
