FROM dlanguage/dmd:latest AS build

WORKDIR /workspace
COPY . .
RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /workspace/build/uim-sap-atp-service /app/uim-sap-atp-service

ENV ATP_HOST=0.0.0.0 \
    ATP_PORT=8097 \
    ATP_BASE_PATH=/api/automation-pilot \
    ATP_SERVICE_NAME=uim-sap-atp \
    ATP_SERVICE_VERSION=1.0.0 \
    ATP_AI_PROVIDER=mock-genai

EXPOSE 8097

CMD ["/app/uim-sap-atp-service"]
