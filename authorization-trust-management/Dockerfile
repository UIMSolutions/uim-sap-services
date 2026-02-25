FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-atm

COPY --from=build /app/build/uim-sap-atm-service ./uim-sap-atm-service

ENV ATM_HOST=0.0.0.0 \
    ATM_PORT=8088 \
    ATM_BASE_PATH=/api/atm

EXPOSE 8088

CMD ["./uim-sap-atm-service"]
