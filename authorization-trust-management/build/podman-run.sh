#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-atm:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-atm}"
HOST_PORT="${HOST_PORT:-8088}"

podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8088 \
  -e ATM_HOST=0.0.0.0 \
  -e ATM_PORT=8088 \
  -e ATM_BASE_PATH=/api/atm \
  -e ATM_DEFAULT_IDP_ISSUER=https://accounts.sap.com \
  -e ATM_DEFAULT_IDP_AUDIENCE=uim-sap-app \
  "$IMAGE_TAG"
