# UIM SAP Data Quality Management Service (DQM)

Kubernetes-compatible SAP Data Quality Management style service built with D, `vibe.d`, and `uim-framework`.

## Features

- Address cleansing to validate, correct, and standardize addresses by country preferences
- Ambiguous address handling with proposal lists to select the correct address candidate
- Geocoding to obtain latitude/longitude from address input
- Reverse geocoding to find nearest addresses from coordinates
- Type-ahead address suggestions for faster and more accurate entry

## Build and Run

```bash
cd "Data Quality Management"
dub build
./build/uim-sap-dqm-service
```

Environment variables:

- `DQM_HOST` (default `0.0.0.0`)
- `DQM_PORT` (default `8091`)
- `DQM_BASE_PATH` (default `/api/dqm`)
- `DQM_SERVICE_NAME` (default `uim-sap-dqm`)
- `DQM_SERVICE_VERSION` (default `1.0.0`)
- `DQM_DEFAULT_COUNTRY` (default `DE`)
- `DQM_AUTH_TOKEN` (optional bearer token)

## Podman Container

```bash
cd "Data Quality Management"
podman build -t uim-sap-dqm:local -f Dockerfile .
podman run --rm -p 8091:8091 --name uim-sap-dqm uim-sap-dqm:local
```

## REST API

Base path: `/api/dqm`

- `GET /health`
- `GET /ready`
- `POST /v1/address/cleanse`
- `POST /v1/geocode`
- `POST /v1/reverse-geocode`
- `POST /v1/address/suggest`

### Example: address cleansing

```bash
curl -X POST "http://localhost:8091/api/dqm/v1/address/cleanse" \
  -H "Content-Type: application/json" \
  -d '{
    "address": {
      "line1": "Friedrichstraße 10",
      "city": "berlin",
      "postal_code": "10117",
      "country": "de"
    },
    "preferences": {
      "uppercase_city": true,
      "keep_line2": false
    }
  }'
```

### Example: geocoding

```bash
curl -X POST "http://localhost:8091/api/dqm/v1/geocode" \
  -H "Content-Type: application/json" \
  -d '{
    "address": {
      "line1": "Dietmar-Hopp-Allee 16",
      "city": "Walldorf",
      "country": "DE"
    }
  }'
```

### Example: type-ahead suggestions

```bash
curl -X POST "http://localhost:8091/api/dqm/v1/address/suggest" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Friedrich",
    "country": "DE",
    "limit": 5
  }'
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
