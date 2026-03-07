FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-em

COPY --from=build /app/build/uim-sap-em-service ./uim-sap-em-service

ENV EVM_HOST=0.0.0.0 \
    EVM_PORT=8092 \
    EVM_BASE_PATH=/api/em

EXPOSE 8092

CMD ["./uim-sap-em-service"]
