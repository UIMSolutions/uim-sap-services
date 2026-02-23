FROM dlanguage/dmd:latest AS build

WORKDIR /workspace
COPY . .
RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /workspace/build/uim-sap-cmg-service /app/uim-sap-cmg-service

ENV CMG_HOST=0.0.0.0 \
    CMG_PORT=8095 \
    CMG_BASE_PATH=/api/cmg \
    CMG_SERVICE_NAME=uim-sap-cmg \
    CMG_SERVICE_VERSION=1.0.0

EXPOSE 8095

CMD ["/app/uim-sap-cmg-service"]
