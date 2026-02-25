FROM docker.io/dlanguage/dmd:latest AS build

WORKDIR /workspace
COPY . .
RUN dub build --build=release

FROM docker.io/library/ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /workspace/build/uim-sap-bas-service /app/uim-sap-bas-service

ENV BAS_HOST=0.0.0.0 \
    BAS_PORT=8088 \
    BAS_BASE_PATH=/api/business-application-studio \
    BAS_SERVICE_NAME=uim-sap-bas \
    BAS_SERVICE_VERSION=1.0.0 \
    BAS_DEFAULT_REGION=eu10

EXPOSE 8088

CMD ["/app/uim-sap-bas-service"]
