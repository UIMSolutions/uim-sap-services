FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-ctm

COPY --from=build /app/build/uim-sap-ctm-service ./uim-sap-ctm-service

ENV CTM_HOST=0.0.0.0 \
    CTM_PORT=8100 \
    CTM_BASE_PATH=/api/cloud-transport \
    CTM_SERVICE_NAME=uim-sap-ctm \
    CTM_SERVICE_VERSION=1.0.0 \
    CTM_RUNTIME=cloud-foundry

EXPOSE 8100

CMD ["./uim-sap-ctm-service"]
