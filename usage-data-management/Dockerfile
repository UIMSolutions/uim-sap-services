FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-usage-data-management

COPY --from=build /app/build/uim-usage-data-management-service ./uim-usage-data-management-service

ENV UDM_HOST=0.0.0.0 \
    UDM_PORT=8109 \
    UDM_BASE_PATH=/api/usage-data-management

EXPOSE 8109

CMD ["./uim-usage-data-management-service"]
