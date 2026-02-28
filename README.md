# uim-sap

`uim-sap` is a D language monorepo for SAP/BTP-oriented libraries and service implementations.

It contains:
- A root DUB library package (`uim-sap`)
- Shared foundational modules (for example `service/`)
- Many standalone service packages (for example `cloud-identity/`, `advanced-event-mesh/`, `authorization-trust-management/`, `content-manager/`)
- Deployment assets (`Dockerfile`, `k8s/`, `build/`) inside most service folders

## Repository layout

- `dub.sdl` - root package definition (`targetType "library"`)
- `source/` - root module sources
- `service/` - shared package used by multiple services
- `<service-name>/` - independent DUB subpackages with their own `dub.sdl`, source, and runtime assets
- `uim-sap-test-library/` - test helper package

## Requirements

- D compiler (for example `dmd`)
- `dub`
- `openssl` development/runtime libraries (used by `vibe.d` TLS stack)

## Build

Build the root library package:

```bash
dub build
```

Run all root-package unittests:

```bash
dub test
```

## Work with a service package

Most runnable services are built and started from their own folder.

Example (`cloud-identity`):

```bash
cd cloud-identity
dub run
```

Example (`advanced-event-mesh`):

```bash
cd advanced-event-mesh
dub run
```

Run tests for a specific package:

```bash
cd content-manager
dub test
```

## Common service conventions

Most service packages use a similar structure:
- `source/` - application and service code
- `build/` - local run helpers or built artifacts
- `k8s/` - Kubernetes manifests
- `Dockerfile` - container image definition

Most services also expose environment variables for host, port, base path, service name/version, and optional bearer token auth.

## Notes

- Running `dub run` at repository root will not start a service because the root target is a library.
- Prefer running commands from the specific service directory you want to build/test/run.

## License

Apache-2.0. See [LICENSE](LICENSE).
