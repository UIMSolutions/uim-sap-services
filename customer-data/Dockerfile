FROM dlanguage/dmd:latest AS build

WORKDIR /workspace
COPY . .
RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /workspace/build/uim-sap-customer-data-service /app/uim-sap-customer-data-service

ENV CDC_HOST=0.0.0.0 \
    CDC_PORT=8097 \
    CDC_BASE_PATH=/api/customer-data \
    CDC_SERVICE_NAME=uim-sap-customer-data \
    CDC_SERVICE_VERSION=1.0.0 \
    CDC_DATA_DIR=/var/lib/uim-customer-data \
    CDC_CACHE_FILE=customer-data-cache.json \
    CDC_DEFAULT_REGION=eu-central

EXPOSE 8097

CMD ["/app/uim-sap-customer-data-service"]
