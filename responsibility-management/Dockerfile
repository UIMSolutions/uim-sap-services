FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-rms

COPY --from=build /app/build/uim-sap-responsibility-management-service ./uim-sap-responsibility-management-service

ENV RMS_HOST=0.0.0.0 \
    RMS_PORT=8095 \
    RMS_BASE_PATH=/api/rms \
    RMS_DATA_DIR=/var/lib/uim-rms \
    RMS_DEFAULT_TENANT=provider \
    RMS_DEFAULT_SPACE=dev \
    RMS_LOG_RETENTION=500

VOLUME ["/var/lib/uim-rms"]

EXPOSE 8095

CMD ["./uim-sap-responsibility-management-service"]
