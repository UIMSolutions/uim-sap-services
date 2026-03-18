FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-slm

COPY --from=build /app/build/uim-slm-service ./uim-slm-service

ENV SLM_HOST=0.0.0.0 \
    SLM_PORT=8120 \
    SLM_BASE_PATH=/api/solution-lifecycle \
    SLM_SERVICE_NAME=uim-sap-slm \
    SLM_SERVICE_VERSION=1.0.0 \
    SLM_RUNTIME=cloud-foundry

EXPOSE 8120

CMD ["./uim-slm-service"]
