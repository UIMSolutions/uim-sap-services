FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-alert-notification

COPY --from=build /app/build/uim-alert-notification-service ./uim-alert-notification-service

ENV ALERT_HOST=0.0.0.0 \
    ALERT_PORT=8097 \
    ALERT_BASE_PATH=/api/alert-notification

EXPOSE 8097

CMD ["./uim-alert-notification-service"]
