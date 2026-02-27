# Customer Data Service

This service provides an Customer Data Cloud-style runtime for unified customer identity, consent, authentication, and risk-aware access.

## Features

- Unified customer profile model for website and app user engagement.
- Customer identity APIs to collect and securely store user information.
- Consent and preference management with transparent, auditable records.
- Region-aware profile storage and global-access site grouping.
- Account Take Over protection via login-attempt lockout controls.
- Risk Based Authentication with provider signal support for:
  - Google reCAPTCHA
  - Akamai
  - Arkose Labs
  - Transunion
  - custom providers

## Build

```bash
dub build --root=./customer-data
```

## Run

```bash
CDC_AUTH_TOKEN=local-token dub run --root=./customer-data
```

Defaults:

- Host: `0.0.0.0`
- Port: `8097`
- Base path: `/api/customer-data`
- Data dir: `/tmp/uim-customer-data`

## API

### Ops

- `GET /api/customer-data/health`
- `GET /api/customer-data/ready`

### Profiles (Identity)

- `POST /api/customer-data/v1/tenants/{tenantId}/profiles`
- `GET /api/customer-data/v1/tenants/{tenantId}/profiles`
- `GET /api/customer-data/v1/tenants/{tenantId}/profiles/{userId}`

Example upsert profile payload:

```json
{
  "user_id": "user-1001",
  "email": "maria@example.com",
  "phone": "+49-123-456",
  "first_name": "Maria",
  "last_name": "Meyer",
  "region": "eu-central",
  "site_group_id": "brand-emea",
  "password": "demo-password",
  "active": true,
  "email_verified": true,
  "preferences": {
    "newsletter": true,
    "language": "de"
  },
  "custom_attributes": {
    "loyalty_tier": "gold"
  }
}
```

### Consent and Preferences

- `POST /api/customer-data/v1/tenants/{tenantId}/profiles/{userId}/consents`
- `GET /api/customer-data/v1/tenants/{tenantId}/profiles/{userId}/consents`

Example consent payload:

```json
{
  "consent_id": "email-marketing-v1",
  "purpose": "Email Marketing",
  "legal_basis": "consent",
  "status": "granted",
  "source": "preference-center",
  "language": "en"
}
```

### Global Access and Regional Storage

- `POST /api/customer-data/v1/tenants/{tenantId}/site-groups`
- `GET /api/customer-data/v1/tenants/{tenantId}/site-groups`
- `GET /api/customer-data/v1/tenants/{tenantId}/global-access/resolve/{userId}?site={site}`

Example site group payload:

```json
{
  "group_id": "brand-emea",
  "name": "Brand Europe",
  "sites": ["shop.de", "shop.fr", "shop.es"],
  "regions": ["eu-central", "eu-west"]
}
```

### Risk Providers and Authentication Security

- `POST /api/customer-data/v1/tenants/{tenantId}/risk-providers`
- `GET /api/customer-data/v1/tenants/{tenantId}/risk-providers`
- `POST /api/customer-data/v1/tenants/{tenantId}/authenticate`
- `GET /api/customer-data/v1/tenants/{tenantId}/auth-events?limit=100`

Risk provider payload:

```json
{
  "provider_id": "recaptcha-main",
  "name": "Google reCAPTCHA",
  "provider_kind": "google-recaptcha",
  "enabled": true,
  "config": {
    "site_key": "demo-site-key"
  }
}
```

Authentication payload:

```json
{
  "user_id": "user-1001",
  "password": "demo-password",
  "ip_address": "203.0.113.42",
  "provider_signals": {
    "recaptcha_score": 0.81,
    "akamai_risk": false,
    "arkose_result": "clean",
    "transunion_score": 420,
    "impossible_travel": false
  }
}
```

## Podman

Build image:

```bash
podman build -t uim-sap-customer-data:latest ./customer-data
```

Run container:

```bash
podman run --rm -p 8097:8097 \
  -e CDC_AUTH_TOKEN=local-token \
  -e CDC_DATA_DIR=/var/lib/uim-customer-data \
  -v customer-data-cache:/var/lib/uim-customer-data \
  uim-sap-customer-data:latest
```

## Kubernetes

Apply manifests:

```bash
kubectl apply -f ./customer-data/k8s/configmap.yaml
kubectl apply -f ./customer-data/k8s/deployment.yaml
kubectl apply -f ./customer-data/k8s/service.yaml
```

Optional auth secret:

```bash
kubectl create secret generic uim-sap-customer-data-secret \
  --from-literal=authToken=local-token
```
