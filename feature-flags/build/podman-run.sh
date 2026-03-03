#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-ff:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-ff}"
HOST_PORT="${HOST_PORT:-8094}"

podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8094 \
  -e FF_HOST=0.0.0.0 \
  -e FF_PORT=8094 \
  -e FF_BASE_PATH=/api/ff \
  "$IMAGE_TAG"
