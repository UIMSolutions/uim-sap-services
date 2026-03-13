FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-prm

COPY --from=build /app/build/uim-prm-service ./uim-prm-service

ENV PRM_HOST=0.0.0.0 \
    PRM_PORT=8096 \
    PRM_BASE_PATH=/api/prm \
    PRM_DEFAULT_CAPACITY_HOURS=8

EXPOSE 8096

CMD ["./uim-prm-service"]
