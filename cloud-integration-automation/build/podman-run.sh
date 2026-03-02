#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-cloud-integration-automation:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-cloud-integration-automation}"
HOST_PORT="${HOST_PORT:-8098}"

echo "Building image: $IMAGE_TAG"
podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

echo "Starting container on port $HOST_PORT..."
podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8098 \
  -e CIA_HOST=0.0.0.0 \
  -e CIA_PORT=8098 \
  -e CIA_BASE_PATH=/api/cloud-integration-automation \
  -e CIA_SERVICE_NAME=uim-sap-cloud-integration-automation \
  -e CIA_SERVICE_VERSION=1.0.0 \
  -e CIA_RUNTIME=cloud-foundry \
  "$IMAGE_TAG"
