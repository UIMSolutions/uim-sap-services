# SAP Mobile Services

A service similar to "SAP Mobile Services" built with D, uim-framework, and vibe.d.

The channel for mobile development: build and deploy native apps using MDK,
SAP BTP SDK for iOS, or SAP BTP SDK for Android. Manage application lifecycle,
push notifications, offline data, security policies, and usage analytics.

## Features

| Feature | Description |
|---------|-------------|
| **App Lifecycle** | Define, manage, and monitor mobile apps through their entire lifecycles |
| **App Updates** | Manage versions with OTA deployment; activate, deprecate, retire releases |
| **Push Notifications** | Configure APNs/FCM/WNS providers; send targeted or broadcast notifications |
| **Work Offline** | OData synchronization with delta/full/on-demand strategies and encrypted local stores |
| **Security** | Authentication types (OAuth2, SAML, X.509, biometric), passcode policies, jailbreak detection |
| **User Management** | Register user connections; lock, wipe, unlock, and delete user data |
| **Usage Analytics** | Per-app and global metrics: users, sessions, push delivery, versions |
| **SDK Catalog** | Browse available SDKs (MDK, iOS, Android) with version information |

## API Reference

Base path: `/api/mob`

### Health & Metrics

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/ready` | Readiness check |
| GET | `/v1/metrics` | Global platform metrics |

### SDKs

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/sdks` | List available SDKs |
| GET | `/v1/sdks/{type}` | Get SDK details (mdk, ios, android) |

### Applications

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/apps` | List all applications |
| POST | `/v1/apps/{appId}` | Create application |
| PUT | `/v1/apps/{appId}` | Update application |
| GET | `/v1/apps/{appId}` | Get application details |
| DELETE | `/v1/apps/{appId}` | Delete application and all resources |

### App Versions / Updates

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/apps/{appId}/versions` | List versions |
| POST | `/v1/apps/{appId}/versions/{ver}` | Create version |
| GET | `/v1/apps/{appId}/versions/{ver}` | Get version details |
| DELETE | `/v1/apps/{appId}/versions/{ver}` | Delete version |
| POST | `/v1/apps/{appId}/versions/{ver}/activate` | Activate version (OTA rollout) |

### Push Notifications

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/apps/{appId}/push/config` | Get push configuration |
| PUT | `/v1/apps/{appId}/push/config` | Set push configuration |
| POST | `/v1/apps/{appId}/push/send` | Send push notification |
| GET | `/v1/apps/{appId}/push/history` | Get notification history |

### Offline Configuration

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/apps/{appId}/offline` | Get offline/OData sync config |
| PUT | `/v1/apps/{appId}/offline` | Set offline/OData sync config |

### Security Policies

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/apps/{appId}/security` | Get security policy |
| PUT | `/v1/apps/{appId}/security` | Set security policy |

### User Management

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/apps/{appId}/users` | List user connections |
| POST | `/v1/apps/{appId}/users/{userId}` | Register user connection |
| GET | `/v1/apps/{appId}/users/{userId}` | Get user connection |
| DELETE | `/v1/apps/{appId}/users/{userId}` | Delete user connection |
| POST | `/v1/apps/{appId}/users/{userId}/lock` | Lock user |
| POST | `/v1/apps/{appId}/users/{userId}/unlock` | Unlock user |
| POST | `/v1/apps/{appId}/users/{userId}/wipe` | Wipe user data |

### Usage Analytics

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/apps/{appId}/analytics` | Get app usage report |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MOB_HOST` | `0.0.0.0` | Bind address |
| `MOB_PORT` | `8089` | Listen port |
| `MOB_BASE_PATH` | `/api/mob` | API base path |
| `MOB_SERVICE_NAME` | `uim-mob` | Service name in responses |
| `MOB_SERVICE_VERSION` | `1.0.0` | Service version |
| `MOB_AUTH_TOKEN` | *(empty)* | Bearer token; enables auth when set |
| `MOB_MAX_APPLICATIONS` | `500` | Max applications |
| `MOB_MAX_VERSIONS_PER_APP` | `100` | Max versions per application |
| `MOB_MAX_USERS_PER_APP` | `10000` | Max user connections per application |
| `MOB_MAX_NOTIFICATIONS_PER_APP` | `5000` | Max retained notifications per app |
| `MOB_DEFAULT_SYNC_INTERVAL` | `300` | Default offline sync interval (seconds) |

## Build & Run

```bash
# Build
make build

# Run locally
make run

# Container
make container-build
make container-run
```

## Kubernetes Deployment

```bash
make k8s-apply    # Deploy
make k8s-delete   # Tear down
```

## License

Apache-2.0
