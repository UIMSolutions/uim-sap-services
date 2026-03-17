FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-data-retention

COPY --from=build /app/build/uim-data-retention-service ./uim-data-retention-service

ENV DRM_HOST=0.0.0.0 \
    DRM_PORT=8110 \
    DRM_BASE_PATH=/api/data-retention

EXPOSE 8110

CMD ["./uim-data-retention-service"]
