#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-aem:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-aem}"
HOST_PORT="${HOST_PORT:-8088}"

podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8088 \
  -e AEM_HOST=0.0.0.0 \
  -e AEM_PORT=8088 \
  -e AEM_BASE_PATH=/api/aem \
  -e AEM_DEFAULT_REGION=eu10 \
  "$IMAGE_TAG"
