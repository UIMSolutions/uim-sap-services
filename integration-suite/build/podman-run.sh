#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-is:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-is}"
HOST_PORT="${HOST_PORT:-8100}"

podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8100 \
  -e IS_HOST=0.0.0.0 \
  -e IS_PORT=8100 \
  -e IS_BASE_PATH=/api/is \
  "$IMAGE_TAG"
