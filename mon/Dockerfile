FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-mon

COPY --from=build /app/build/uim-sap-mon-service ./uim-sap-mon-service

ENV MON_HOST=0.0.0.0 \
    MON_PORT=8090 \
    MON_BASE_PATH=/api/mon

EXPOSE 8090

CMD ["./uim-sap-mon-service"]
