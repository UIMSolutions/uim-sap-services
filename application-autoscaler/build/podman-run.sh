#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-aas:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-aas}"
HOST_PORT="${HOST_PORT:-8086}"

podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8086 \
  -e AAS_HOST=0.0.0.0 \
  -e AAS_PORT=8086 \
  -e AAS_BASE_PATH=/api/autoscaler \
  -e AAS_CF_API=https://api.cf.example \
  "$IMAGE_TAG"
