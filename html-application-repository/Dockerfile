FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-html5-app-repo

COPY --from=build /app/build/uim-sap-html5-app-repo-service ./uim-sap-html5-app-repo-service

ENV HTM_REPO_HOST=0.0.0.0 \
    HTM_REPO_PORT=8094 \
    HTM_REPO_BASE_PATH=/api/html5-repo \
    HTM_REPO_DATA_DIR=/var/lib/uim-html5-repo \
    HTM_REPO_CACHE_TTL_SECONDS=120 \
    HTM_REPO_DEFAULT_TENANT=provider \
    HTM_REPO_DEFAULT_SPACE=dev \
    HTM_REPO_ALLOW_PUBLIC_CROSS_SPACE=true

VOLUME ["/var/lib/uim-html5-repo"]

EXPOSE 8094

CMD ["./uim-sap-html5-app-repo-service"]
