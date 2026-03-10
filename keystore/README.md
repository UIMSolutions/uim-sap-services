# UIM Keystore Service (KST)

Kubernetes-compatible Keystore service that emulates key parts of **SAP Keystore Service** APIs using D, `vibe.d`, and `uim-framework`.

A repository for cryptographic keys and certificates. Retrieve keystores easily in your applications, and use them in various cryptographic operations, such as signing and verifying digital signatures, encrypting and decrypting messages, and performing SSL communication.

## Features

- **Manage keystores** – Create, list, retrieve, update, and delete named keystores
- **Key management** – Store and retrieve cryptographic key entries (private keys, secret keys, key pairs) with encrypted-at-rest storage
- **Certificate management** – Store and retrieve X.509 certificates and trusted certificates
- **Digital signatures** – Sign data and verify signatures using stored keys
- **Encryption / Decryption** – Encrypt and decrypt messages using stored keys
- **Client certificate authentication** – Validate client certificates against a trusted certificate store
- **Health & readiness probes** – Kubernetes-ready `/health` and `/ready` endpoints
- **Bearer token auth** – Optional authentication via `Authorization: Bearer <token>`
- **Caller-provided encryption keys** – Supply an encryption key per-request via `X-KST-Encryption-Key` header or `encryption_key` in the request body

## Build & Run

```bash
cd keystore
dub build
./build/uim-kst-service
```

### Using Podman

```bash
# Build container image
podman build -t ghcr.io/uimsolutions/uim-sap-kst:latest .

# Run container
podman run --rm -p 8087:8087 \
  -e KST_HOST=0.0.0.0 \
  -e KST_PORT=8087 \
  -e KST_MASTER_KEY=my-secret-master-key \
  ghcr.io/uimsolutions/uim-sap-kst:latest
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `KST_HOST` | `0.0.0.0` | Bind address |
| `KST_PORT` | `8087` | Listen port |
| `KST_BASE_PATH` | `/api/kst` | Base URL path |
| `KST_SERVICE_NAME` | `uim-kst` | Service name in metadata |
| `KST_SERVICE_VERSION` | `1.0.0` | Service version in metadata |
| `KST_AUTH_TOKEN` | *(none)* | Bearer token for authentication (enables auth when set) |
| `KST_MASTER_KEY` | `uim-kst-dev-master-key` | Master encryption key for key material at rest |
| `KST_MAX_KEYSTORES` | `0` | Maximum keystores (0 = unlimited) |
| `KST_ENABLE_CLIENT_CERT_AUTH` | `false` | Enable client certificate authentication endpoint |

## REST API

Base path: `/api/kst`

### Health & Readiness

- `GET /health` – Service health check
- `GET /ready` – Readiness probe

### Keystores

- `GET    /v1/keystores` – List all keystores
- `POST   /v1/keystores/{name}` – Create a keystore
- `PUT    /v1/keystores/{name}` – Update a keystore
- `GET    /v1/keystores/{name}` – Get keystore details (with keys and certificates)
- `DELETE /v1/keystores/{name}` – Delete a keystore

### Key Entries

- `GET    /v1/keystores/{name}/keys` – List key entries
- `PUT    /v1/keystores/{name}/keys/{alias}` – Create or update a key entry
- `GET    /v1/keystores/{name}/keys/{alias}` – Retrieve key entry (with decrypted material)
- `DELETE /v1/keystores/{name}/keys/{alias}` – Delete a key entry

### Certificates

- `GET    /v1/keystores/{name}/certificates` – List certificates
- `PUT    /v1/keystores/{name}/certificates/{alias}` – Create or update a certificate
- `GET    /v1/keystores/{name}/certificates/{alias}` – Retrieve certificate
- `DELETE /v1/keystores/{name}/certificates/{alias}` – Delete a certificate

### Cryptographic Operations

- `POST /v1/keystores/{name}/keys/{alias}/sign` – Sign data
- `POST /v1/keystores/{name}/keys/{alias}/verify` – Verify a signature
- `POST /v1/keystores/{name}/keys/{alias}/encrypt` – Encrypt plaintext
- `POST /v1/keystores/{name}/keys/{alias}/decrypt` – Decrypt ciphertext

### Client Certificate Authentication

- `POST /v1/auth/client-cert` – Validate a client certificate against trusted store

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## License

Apache-2.0
