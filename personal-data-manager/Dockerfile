FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-pdm

COPY --from=build /app/build/uim-pdm-service ./uim-pdm-service

ENV PDM_HOST=0.0.0.0 \
    PDM_PORT=8092 \
    PDM_BASE_PATH=/api/pdm

EXPOSE 8092

CMD ["./uim-pdm-service"]
