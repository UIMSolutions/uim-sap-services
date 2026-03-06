FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-ip

COPY --from=build /app/build/uim-sap-ip-service ./uim-sap-ip-service

ENV IPV_HOST=0.0.0.0 \
    IPV_PORT=8095 \
    IPV_BASE_PATH=/api/ip

EXPOSE 8095

CMD ["./uim-sap-ip-service"]
