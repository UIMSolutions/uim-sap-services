#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-isa:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-isa}"
HOST_PORT="${HOST_PORT:-8088}"

podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8088 \
  -e ISA_HOST=0.0.0.0 \
  -e ISA_PORT=8088 \
  -e ISA_BASE_PATH=/api/situation-automation \
  "$IMAGE_TAG"
