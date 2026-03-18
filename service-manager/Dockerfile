FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-service-manager

COPY --from=build /app/build/uim-service-manager-service ./uim-service-manager-service

ENV SVM_HOST=0.0.0.0 \
    SVM_PORT=8111 \
    SVM_BASE_PATH=/api/service-manager

EXPOSE 8111

CMD ["./uim-service-manager-service"]
