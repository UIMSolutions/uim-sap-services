FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-dst

COPY --from=build /app/build/uim-sap-dst-service ./uim-sap-dst-service

ENV DST_HOST=0.0.0.0 \
    DST_PORT=8104 \
    DST_BASE_PATH=/api/destination \
    DST_SERVICE_NAME=uim-sap-dst \
    DST_SERVICE_VERSION=1.0.0 \
    DST_RUNTIME=cloud-foundry

EXPOSE 8104

CMD ["./uim-sap-dst-service"]
