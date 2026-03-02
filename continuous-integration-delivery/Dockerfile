FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-cid

COPY --from=build /app/build/uim-sap-cid-service ./uim-sap-cid-service

ENV CID_HOST=0.0.0.0 \
    CID_PORT=8102 \
    CID_BASE_PATH=/api/cicd \
    CID_SERVICE_NAME=uim-sap-cid \
    CID_SERVICE_VERSION=1.0.0 \
    CID_RUNTIME=cloud-foundry

EXPOSE 8102

CMD ["./uim-sap-cid-service"]
