FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-aem

COPY --from=build /app/build/uim-sap-aem-service ./uim-sap-aem-service

ENV AEM_HOST=0.0.0.0 \
    AEM_PORT=8088 \
    AEM_BASE_PATH=/api/aem

EXPOSE 8088

CMD ["./uim-sap-aem-service"]
