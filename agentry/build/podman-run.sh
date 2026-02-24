#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-agentry:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-agentry}"
HOST_PORT="${HOST_PORT:-8089}"

podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8089 \
  -e AGENTRY_HOST=0.0.0.0 \
  -e AGENTRY_PORT=8089 \
  -e AGENTRY_BASE_PATH=/api/agentry \
  "$IMAGE_TAG"
