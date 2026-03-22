/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pdm.config;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

class PDMConfig : SAPConfig {
  mixin(SAPConfigTemplate!PDMConfig);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    basePath(initData.getString("basePath", "/api/pdm"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8092));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-pdm"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    // Default tenant configuration
    defaultTenantId = randomUUID();

    return true;
  }

  /// Maximum data subjects per tenant
  size_t maxSubjectsPerTenant = 100_000;

  /// Maximum active requests per tenant
  size_t maxRequestsPerTenant = 10_000;

  /// Maximum personal data records per subject
  size_t maxRecordsPerSubject = 500;

  /// Request processing timeout in seconds
  size_t requestTimeoutSecs = 86_400;

  /// Default tenant ID for single-tenant mode
  UUID defaultTenantId;

  /// Enable multitenancy
  bool multitenancy = true;

  override void validate() {
    super.validate();

    if (maxSubjectsPerTenant == 0) {
      throw new PDMConfigurationException("maxSubjectsPerTenant must be greater than zero");
    }
  }
}
