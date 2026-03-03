#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-em:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-em}"
HOST_PORT="${HOST_PORT:-8092}"

podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8092 \
  -e EM_HOST=0.0.0.0 \
  -e EM_PORT=8092 \
  -e EM_BASE_PATH=/api/em \
  "$IMAGE_TAG"
