FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-mdg

COPY --from=build /app/build/uim-sap-mdg-service ./uim-sap-mdg-service

ENV MDG_HOST=0.0.0.0 \
    MDG_PORT=8087 \
    MDG_BASE_PATH=/api/mdg \
    MDG_DEFAULT_APPROVER=mdg-approver

EXPOSE 8087

CMD ["./uim-sap-mdg-service"]
