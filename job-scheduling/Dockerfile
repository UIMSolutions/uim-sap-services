FROM dlang2/dmd-ubuntu:2.111.0 AS build

WORKDIR /app

COPY dub.sdl ./
COPY source ./source

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/uim-sap-job-scheduling

COPY --from=build /app/build/uim-sap-job-scheduling-service ./uim-sap-job-scheduling-service

ENV JOBS_HOST=0.0.0.0 \
    JOBS_PORT=8101 \
    JOBS_BASE_PATH=/api/job-scheduling \
    JOBS_SCHEDULER_TICK_MS=1000

EXPOSE 8101

CMD ["./uim-sap-job-scheduling-service"]
