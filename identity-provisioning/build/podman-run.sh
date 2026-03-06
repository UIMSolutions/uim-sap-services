#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-uim-sap-ip:local}"
CONTAINER_NAME="${CONTAINER_NAME:-uim-sap-ip}"
HOST_PORT="${HOST_PORT:-8095}"

podman build -t "$IMAGE_TAG" .

podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

podman run --name "$CONTAINER_NAME" --rm \
  -p "$HOST_PORT":8095 \
  -e IPV_HOST=0.0.0.0 \
  -e IPV_PORT=8095 \
  -e IPV_BASE_PATH=/api/ip \
  "$IMAGE_TAG"
