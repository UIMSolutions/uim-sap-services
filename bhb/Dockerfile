FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-buh

COPY --from=build /app/build/uim-sap-buh-service ./uim-sap-buh-service

ENV BUH_HOST=0.0.0.0 \
    BUH_PORT=8083 \
    BUH_BASE_PATH=/api/hub

EXPOSE 8083

CMD ["./uim-sap-buh-service"]
