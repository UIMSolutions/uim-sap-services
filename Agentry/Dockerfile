FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-agentry

COPY --from=build /app/build/uim-sap-agentry-service ./uim-sap-agentry-service

ENV AGENTRY_HOST=0.0.0.0 \
    AGENTRY_PORT=8089 \
    AGENTRY_BASE_PATH=/api/agentry

EXPOSE 8089

CMD ["./uim-sap-agentry-service"]
