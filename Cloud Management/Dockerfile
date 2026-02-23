FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY ../btp ../btp
COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-mgt

COPY --from=build /app/build/uim-sap-mgt-service ./uim-sap-mgt-service

ENV MGT_HOST=0.0.0.0 \
    MGT_PORT=8088 \
    MGT_BASE_PATH=/api/mgt \
    MGT_BTP_REGION=api.sap.hana.ondemand.com

EXPOSE 8088

CMD ["./uim-sap-mgt-service"]
