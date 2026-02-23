FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-con

COPY --from=build /app/build/uim-sap-con-service ./uim-sap-con-service

ENV CON_HOST=0.0.0.0 \
    CON_PORT=8085 \
    CON_BASE_PATH=/api/con \
    CON_CONNECTOR_LOCATION_ID=default-location

EXPOSE 8085

CMD ["./uim-sap-con-service"]
