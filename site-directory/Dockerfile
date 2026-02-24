FROM dlanguage/dmd:latest AS build

WORKDIR /workspace
COPY . .
RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /workspace/build/uim-sap-sdi-service /app/uim-sap-sdi-service

ENV SDI_HOST=0.0.0.0 \
    SDI_PORT=8096 \
    SDI_BASE_PATH=/api/sitedirectory \
    SDI_SERVICE_NAME=uim-sap-sdi \
    SDI_SERVICE_VERSION=1.0.0

EXPOSE 8096

CMD ["/app/uim-sap-sdi-service"]
