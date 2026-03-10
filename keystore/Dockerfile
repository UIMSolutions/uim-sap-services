FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-kst

COPY --from=build /app/build/uim-kst-service ./uim-kst-service

ENV KST_HOST=0.0.0.0 \
    KST_PORT=8087 \
    KST_BASE_PATH=/api/kst

EXPOSE 8087

CMD ["./uim-kst-service"]
