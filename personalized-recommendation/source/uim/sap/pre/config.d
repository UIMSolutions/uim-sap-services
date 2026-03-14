/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pre.config;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

class PREConfig : SAPConfig {
  mixin(SAPConfigTemplate!PREConfig);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network
    basePath(initData.getString("basePath", "/api/pre"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8093));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-pre"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  /// Maximum items per tenant
  size_t maxItemsPerTenant = 500_000;

  /// Maximum users per tenant
  size_t maxUsersPerTenant = 1_000_000;

  /// Maximum interactions stored per user
  size_t maxInteractionsPerUser = 10_000;

  /// Maximum models per tenant
  size_t maxModelsPerTenant = 50;

  /// Maximum scenarios per tenant
  size_t maxScenariosPerTenant = 100;

  /// Default number of recommendations returned
  size_t defaultRecommendationLimit = 10;

  /// Maximum number of recommendations per request
  size_t maxRecommendationLimit = 100;

  /// Default tenant ID for single-tenant mode
  string defaultTenantId = "default";

  /// Enable multitenancy
  bool multitenancy = true;

  override void validate() {
    super.validate();

    if (maxItemsPerTenant == 0)
      throw new PREConfigurationException("maxItemsPerTenant must be greater than zero");
    if (defaultRecommendationLimit == 0 || defaultRecommendationLimit > maxRecommendationLimit)
      throw new PREConfigurationException(
        "defaultRecommendationLimit must be between 1 and maxRecommendationLimit");
  }
}
