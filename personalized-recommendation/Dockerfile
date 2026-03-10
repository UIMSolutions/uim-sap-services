FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-pre

COPY --from=build /app/build/uim-pre-service ./uim-pre-service

ENV PRE_HOST=0.0.0.0 \
    PRE_PORT=8093 \
    PRE_BASE_PATH=/api/pre

EXPOSE 8093

CMD ["./uim-pre-service"]
