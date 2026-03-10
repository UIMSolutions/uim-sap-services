FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl dub.selections.json ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-mob

COPY --from=build /app/build/uim-mob-service ./uim-mob-service

ENV MOB_HOST=0.0.0.0 \
    MOB_PORT=8089 \
    MOB_BASE_PATH=/api/mob

EXPOSE 8089

CMD ["./uim-mob-service"]
