FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-cps

COPY --from=build /app/build/uim-sap-cps-service ./uim-sap-cps-service

ENV CPS_HOST=0.0.0.0 \
    CPS_PORT=8089 \
    CPS_BASE_PATH=/api/cps \
    CPS_DEFAULT_THEME=sap_fiori_3

EXPOSE 8089

CMD ["./uim-sap-cps-service"]
