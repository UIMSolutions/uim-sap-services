FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-isa

COPY --from=build /app/build/uim-sap-isa-service ./uim-sap-isa-service

ENV ISA_HOST=0.0.0.0 \
    ISA_PORT=8088 \
    ISA_BASE_PATH=/api/situation-automation

EXPOSE 8088

CMD ["./uim-sap-isa-service"]
