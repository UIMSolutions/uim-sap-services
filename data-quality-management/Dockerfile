FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-dqm

COPY --from=build /app/build/uim-sap-dqm-service ./uim-sap-dqm-service

ENV DQM_HOST=0.0.0.0 \
    DQM_PORT=8091 \
    DQM_BASE_PATH=/api/dqm \
    DQM_DEFAULT_COUNTRY=DE

EXPOSE 8091

CMD ["./uim-sap-dqm-service"]
