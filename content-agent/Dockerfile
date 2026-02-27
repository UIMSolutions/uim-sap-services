FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-content-agent

COPY --from=build /app/build/uim-sap-content-agent-service ./uim-sap-content-agent-service

ENV CAG_HOST=0.0.0.0 \
    CAG_PORT=8096 \
    CAG_BASE_PATH=/api/content-agent

EXPOSE 8096

CMD ["./uim-sap-content-agent-service"]
