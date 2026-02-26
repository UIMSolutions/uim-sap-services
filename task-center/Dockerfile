FROM dlanguage/dmd:latest AS build

WORKDIR /workspace
COPY . .
RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /workspace/build/uim-sap-task-center-service /app/uim-sap-task-center-service

ENV TC_HOST=0.0.0.0 \
    TC_PORT=8096 \
    TC_BASE_PATH=/api/task-center \
    TC_SERVICE_NAME=uim-sap-task-center \
    TC_SERVICE_VERSION=1.0.0 \
    TC_DATA_DIR=/var/lib/uim-task-center \
    TC_CACHE_FILE=task-cache.json

EXPOSE 8096

CMD ["/app/uim-sap-task-center-service"]
