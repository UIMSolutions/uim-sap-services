FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-mdi

COPY --from=build /app/build/uim-sap-mdi-service ./uim-sap-mdi-service

ENV MDI_HOST=0.0.0.0 \
    MDI_PORT=8092 \
    MDI_BASE_PATH=/api/mdi \
    MDI_DEFAULT_OBJECT_TYPE=business_partner

EXPOSE 8092

CMD ["./uim-sap-mdi-service"]
