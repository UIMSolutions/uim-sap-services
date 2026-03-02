#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-cid:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-cid}"
HOST_PORT="${HOST_PORT:-8102}"

echo "Building image: $IMAGE_TAG"
podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

echo "Starting container on port $HOST_PORT..."
podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8102 \
  -e CID_HOST=0.0.0.0 \
  -e CID_PORT=8102 \
  -e CID_BASE_PATH=/api/cicd \
  -e CID_SERVICE_NAME=uim-sap-cid \
  -e CID_SERVICE_VERSION=1.0.0 \
  -e CID_RUNTIME=cloud-foundry \
  "$IMAGE_TAG"
