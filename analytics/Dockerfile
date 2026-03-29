FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-analytics

COPY --from=build /app/build/uim-sap-analytics-service ./uim-sap-analytics-service

ENV ANALYTICS_HOST=0.0.0.0 \
    ANALYTICS_PORT=8090 \
    ANALYTICS_BASE_PATH=/api/analytics

EXPOSE 8090

CMD ["./uim-sap-analytics-service"]
