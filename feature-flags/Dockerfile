FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-ff

COPY --from=build /app/build/uim-sap-ff-service ./uim-sap-ff-service

ENV FF_HOST=0.0.0.0 \
    FF_PORT=8094 \
    FF_BASE_PATH=/api/ff

EXPOSE 8094

CMD ["./uim-sap-ff-service"]
