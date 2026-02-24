FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-aas

COPY --from=build /app/build/uim-sap-aas-service ./uim-sap-aas-service

ENV AAS_HOST=0.0.0.0 \
    AAS_PORT=8086 \
    AAS_BASE_PATH=/api/autoscaler

EXPOSE 8086

CMD ["./uim-sap-aas-service"]
