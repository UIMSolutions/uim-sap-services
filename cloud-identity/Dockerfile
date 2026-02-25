FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-cis

COPY --from=build /app/build/uim-sap-cis-service ./uim-sap-cis-service

ENV CIS_HOST=0.0.0.0 \
    CIS_PORT=8088 \
    CIS_BASE_PATH=/api/cis \
    CIS_DEFAULT_AUTH_METHOD=form

EXPOSE 8088

CMD ["./uim-sap-cis-service"]
