FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-datasphere

COPY --from=build /app/build/uim-sap-datasphere-service ./uim-sap-datasphere-service

ENV DATASPHERE_HOST=0.0.0.0 \
    DATASPHERE_PORT=8098 \
    DATASPHERE_BASE_PATH=/api/datasphere \
    DATASPHERE_DEFAULT_SPACE_DISK_GB=50 \
    DATASPHERE_DEFAULT_SPACE_MEMORY_GB=16

EXPOSE 8098

CMD ["./uim-sap-datasphere-service"]
