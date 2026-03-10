FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-obs

COPY --from=build /app/build/uim-obs-service ./uim-obs-service

ENV OBS_HOST=0.0.0.0 \
    OBS_PORT=8091 \
    OBS_BASE_PATH=/api/obs

EXPOSE 8091

CMD ["./uim-obs-service"]
