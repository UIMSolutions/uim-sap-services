FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-cre

COPY --from=build /app/build/uim-sap-cre-service ./uim-sap-cre-service

ENV CRE_HOST=0.0.0.0 \
    CRE_PORT=8086 \
    CRE_BASE_PATH=/api/cre

EXPOSE 8086

CMD ["./uim-sap-cre-service"]
