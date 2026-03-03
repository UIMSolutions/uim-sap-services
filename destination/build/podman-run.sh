#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-dst:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-dst}"
HOST_PORT="${HOST_PORT:-8104}"

echo "Building image: $IMAGE_TAG"
podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

echo "Starting container on port $HOST_PORT..."
podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8104 \
  -e DST_HOST=0.0.0.0 \
  -e DST_PORT=8104 \
  -e DST_BASE_PATH=/api/destination \
  -e DST_SERVICE_NAME=uim-sap-dst \
  -e DST_SERVICE_VERSION=1.0.0 \
  -e DST_RUNTIME=cloud-foundry \
  "$IMAGE_TAG"
