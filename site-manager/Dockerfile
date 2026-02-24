FROM dlanguage/dmd:latest AS build

WORKDIR /workspace
COPY . .
RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /workspace/build/uim-sap-smg-service /app/uim-sap-smg-service

ENV SMG_HOST=0.0.0.0 \
    SMG_PORT=8094 \
    SMG_BASE_PATH=/api/sitemanager \
    SMG_SERVICE_NAME=uim-sap-smg \
    SMG_SERVICE_VERSION=1.0.0

EXPOSE 8094

CMD ["/app/uim-sap-smg-service"]
