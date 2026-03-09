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

## Services index

| Name                                                                                                                      | Abbreviation | Type    | Status                                                                                                                                                                                                                                     | Purpose                                                    |
| ------------------------------------------------------------------------------------------------------------------------- | ------------ | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------- |
| [abap-runtime](https://github.com/UIMSolutions/uim-sap/blob/3aec5e8a7550fc6776d92ec617bfbf0a112696cc/abap-runtime/README.md) |              | library | [![abap-runtime](https://github.com/UIMSolutions/uim-sap/actions/workflows/abap-runtime.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/blob/main/.github/workflows/abap-runtime.yml)                                                   | ABAP runtime implementation in D.                          |
| [advanced-event-mesh](advanced-event-mesh/README.md)                                                                         | AEM          | service | [![advanced-event-mesh](https://github.com/UIMSolutions/uim-sap/actions/workflows/advanced-event-mesh.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/advanced-event-mesh.yml)                                        | Event streaming, event management, and monitoring service. |
| [agentry](agentry/README.md)                                                                                                 |              | service | [![agentry](https://github.com/UIMSolutions/uim-sap/actions/workflows/agentry.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/agentry.yml)                                                                            | Agentry-like mobile backend runtime service.               |
| [application-autoscaler](application-autoscaler/README.md)                                                                   |              | service | [![application-autoscaler](https://github.com/UIMSolutions/uim-sap/actions/workflows/application-autoscaler.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/application-autoscaler.yml)                               | Cloud Foundry-oriented autoscaling service.                |
| [audit-log](audit-log/README.md)                                                                                             |              | service | [![audit-log](https://github.com/UIMSolutions/uim-sap/actions/workflows/audit-log.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/audit-log.yml)                                                                      | Audit logging service for security/compliance scenarios.   |
| [authorization-trust-management](authorization-trust-management/README.md)                                                   |              | service | [![authorization-trust-management](https://github.com/UIMSolutions/uim-sap/actions/workflows/authorization-trust-management.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/authorization-trust-management.yml)       | Authorization and trust management service.                |
| [automation-pilot](automation-pilot/README.md)                                                                               |              | service | [![automation-pilot](https://github.com/UIMSolutions/uim-sap/actions/workflows/automation-pilot.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/automation-pilot.yml)                                                 | Automation Pilot-like operations automation runtime.       |
| [btp](btp/README.md)                                                                                                         |              | library | [![btp](https://github.com/UIMSolutions/uim-sap/actions/workflows/btp.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/btp.yml)                                                                                        | Core BTP-oriented D library package.                       |
| [business-application-studio](business-application-studio/README.md)                                                         |              | service | [![business-application-studio](https://github.com/UIMSolutions/uim-sap/actions/workflows/business-application-studio.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/business-application-studio.yml)                | Business Application Studio-like backend service.          |
| [business-hub](business-hub/README.md)                                                                                       |              | service | [![business-hub](https://github.com/UIMSolutions/uim-sap/actions/workflows/business-hub.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/business-hub.yml)                                                             | Business Hub-style service.                                |
| [cloud-identity2](cloud-identity2/README.md)                                                                                 |              | library | [![cloud-identity2](https://github.com/UIMSolutions/uim-sap/actions/workflows/cloud-identity2.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/cloud-identity2.yml)                                                    | Cloud Identity Services library (IAS/IPS, SCIM-focused).   |
| [cloud-foundry](cloud-foundry/README.md)                                                                                     |              | service | [![cloud-foundry](https://github.com/UIMSolutions/uim-sap/actions/workflows/cloud-foundry.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/cloud-foundry.yml)                                                          | Cloud Foundry-style API service.                           |
| [cloud-identity](cloud-identity/README.md)                                                                                   |              | service | [![cloud-identity](https://github.com/UIMSolutions/uim-sap/actions/workflows/cloud-identity.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/cloud-identity.yml)                                                       | Cloud Identity Services-style runtime service.             |
| [cloud-integration-client](cloud-integration-client/README.md)                                                               |              | library | [![cloud-integration-client](https://github.com/UIMSolutions/uim-sap/actions/workflows/cloud-integration-client.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/cloud-integration-client.yml)                         | Cloud Integration (CPI) client library.                    |
| [cloud-logging](cloud-logging/README.md)                                                                                     |              | service | [![cloud-logging](https://github.com/UIMSolutions/uim-sap/actions/workflows/cloud-logging.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/cloud-logging.yml)                                                          | Cloud logging service.                                     |
| [cloud-management](cloud-management/README.md)                                                                               |              | service | [![cloud-management](https://github.com/UIMSolutions/uim-sap/actions/workflows/cloud-management.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/cloud-management.yml)                                                 | BTP cloud management service.                              |
| [cloud-portal](cloud-portal/README.md)                                                                                       |              | service | [![cloud-portal](https://github.com/UIMSolutions/uim-sap/actions/workflows/cloud-portal.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/cloud-portal.yml)                                                             | Cloud portal service runtime.                              |
| [connectivity](connectivity/README.md)                                                                                       |              | service | [![connectivity](https://github.com/UIMSolutions/uim-sap/actions/workflows/connectivity.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/connectivity.yml)                                                             | Connectivity bridge/service APIs.                          |
| [content-agent](content-agent/README.md)                                                                                     |              | service | [![content-agent](https://github.com/UIMSolutions/uim-sap/actions/workflows/content-agent.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/content-agent.yml)                                                          | Content Agent-like service.                                |
| [content-manager](content-manager/README.md)                                                                                 |              | service | [![content-manager](https://github.com/UIMSolutions/uim-sap/actions/workflows/content-manager.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/content-manager.yml)                                                    | Content Manager-like runtime for business content.         |
| [credential-store](credential-store/README.md)                                                                               |              | service | [![credential-store](https://github.com/UIMSolutions/uim-sap/actions/workflows/credential-store.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/credential-store.yml)                                                 | Credential Store-like API service.                         |
| [customer-data](customer-data/README.md)                                                                                     |              | service | [![customer-data](https://github.com/UIMSolutions/uim-sap/actions/workflows/customer-data.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/customer-data.yml)                                                          | Customer Data Cloud-style identity/consent service.        |
| [data-privacy-integration](data-privacy-integration/README.md)                                                               |              | service | [![data-privacy-integration](https://github.com/UIMSolutions/uim-sap/actions/workflows/data-privacy-integration.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/data-privacy-integration.yml)                         | Data Privacy Integration-style service.                    |
| [data-quality-management](data-quality-management/README.md)                                                                 |              | service | [![data-quality-management](https://github.com/UIMSolutions/uim-sap/actions/workflows/data-quality-management.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/data-quality-management.yml)                            | Data Quality Management-style service.                     |
| [datasphere](datasphere/README.md)                                                                                           |              | service | [![datasphere](https://github.com/UIMSolutions/uim-sap/actions/workflows/datasphere.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/datasphere.yml)                                                                   | Datasphere-like service.                                   |
| [fiori](fiori/README.md)                                                                                                     |              | library | [![fiori](https://github.com/UIMSolutions/uim-sap/actions/workflows/fiori.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/fiori.yml)                                                                                  | Fiori client library for D.                                |
| [hanaclient](hanaclient/README.md)                                                                                           |              | library | [![hanaclient](https://github.com/UIMSolutions/uim-sap/actions/workflows/hanaclient.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/hanaclient.yml)                                                                   | HANA database client library for D.                        |
| [html-application-repository](html-application-repository/README.md)                                                         |              | service | [![html-application-repository](https://github.com/UIMSolutions/uim-sap/actions/workflows/html-application-repository.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/html-application-repository.yml)                | HTML5 Application Repository-style service.                |
| [idoc](idoc/README.md)                                                                                                       |              | library | [![idoc](https://github.com/UIMSolutions/uim-sap/actions/workflows/idoc.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/idoc.yml)                                                                                     | IDOC client library for D.                                 |
| [intelligent-situation-automation](intelligent-situation-automation/README.md)                                               |              | service | [![intelligent-situation-automation](https://github.com/UIMSolutions/uim-sap/actions/workflows/intelligent-situation-automation.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/intelligent-situation-automation.yml) | Intelligent Situation Automation-like service.             |
| [job-scheduling](job-scheduling/README.md)                                                                                   |              | service | [![job-scheduling](https://github.com/UIMSolutions/uim-sap/actions/workflows/job-scheduling.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/job-scheduling.yml)                                                       | Job Scheduling-style service.                              |
| [malware-scanning](malware-scanning/README.md)                                                                               | MSC          | service | [![malware-scanning](https://github.com/UIMSolutions/uim-sap/actions/workflows/malware-scanning.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/malware-scanning.yml)                                                 | Malware scanning service.                                  |
| [master-data-governance](master-data-governance/README.md)                                                                   |              | service | [![master-data-governance](https://github.com/UIMSolutions/uim-sap/actions/workflows/master-data-governance.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/master-data-governance.yml)                               | Master Data Governance-style service.                      |
| [master-data-integration](master-data-integration/README.md)                                                                 |              | service | [![master-data-integration](https://github.com/UIMSolutions/uim-sap/actions/workflows/master-data-integration.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/master-data-integration.yml)                            | Master Data Integration-style service.                     |
| [monitoring](monitoring/README.md)                                                                                           |              | service | [![monitoring](https://github.com/UIMSolutions/uim-sap/actions/workflows/monitoring.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/monitoring.yml)                                                                   | Monitoring service for BTP-like scenarios.                 |
| [responsibility-management](responsibility-management/README.md)                                                             |              | service | [![responsibility-management](https://github.com/UIMSolutions/uim-sap/actions/workflows/responsibility-management.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/responsibility-management.yml)                      | Responsibility Management-style service.                   |
| [rfc](rfc/README.md)                                                                                                         |              | library | [![rfc](https://github.com/UIMSolutions/uim-sap/actions/workflows/rfc.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/rfc.yml)                                                                                        | RFC adapter library for D applications.                    |
| [s4hana](s4hana/README.md)                                                                                                   |              | library | [![s4hana](https://github.com/UIMSolutions/uim-sap/actions/workflows/s4hana.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/s4hana.yml)                                                                               | S/4HANA client library for D.                              |
| [site-directory](site-directory/README.md)                                                                                   |              | service | [![site-directory](https://github.com/UIMSolutions/uim-sap/actions/workflows/site-directory.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/site-directory.yml)                                                       | Site Directory-like API service.                           |
| [site-manager](site-manager/README.md)                                                                                       | SMG          | service | [![site-manager](https://github.com/UIMSolutions/uim-sap/actions/workflows/site-manager.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/site-manager.yml)                                                             | Site Manager-like design-time API service.                 |
| [task-center](task-center/README.md)                                                                                         | TKC          | service | [![task-center](https://github.com/UIMSolutions/uim-sap/actions/workflows/task-center.yml/badge.svg)](https://github.com/UIMSolutions/uim-sap/actions/workflows/task-center.yml)                                                                | Task Center-style task federation service.                 |

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
