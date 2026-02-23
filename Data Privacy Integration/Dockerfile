FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-dpi

COPY --from=build /app/build/uim-sap-dpi-service ./uim-sap-dpi-service

ENV DPI_HOST=0.0.0.0 \
    DPI_PORT=8093 \
    DPI_BASE_PATH=/api/dpi \
    DPI_DEFAULT_RETENTION_DAYS=365

EXPOSE 8093

CMD ["./uim-sap-dpi-service"]
