/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.analytics.config;

import uim.sap.analytics;

mixin(ShowModule!());

@safe:

class AnalyticsConfig : SAPConfig {
  mixin(SAPConfigTemplate!AnalyticsConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    basePath(initData.getString("basePath", "/api/analytics"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8090));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-analytics"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  int maxStoriesPerTenant = 1000;
  int maxDashboardsPerTenant = 500;
  int maxDatasetsPerTenant = 200;
  int maxModelsPerTenant = 100;
  int maxConnectionsPerTenant = 50;
  int maxUsersPerTenant = 10000;
  int predictionTimeoutSeconds = 300;
  string defaultPlan = "standard";         // "standard", "premium"
  bool datasphereIntegrationEnabled = false;
  string datasphereEndpoint;

  override void validate() {
    super.validate();

    if (maxStoriesPerTenant <= 0) {
      throw new AnalyticsConfigurationException("maxStoriesPerTenant must be greater than zero");
    }

    if (maxDashboardsPerTenant <= 0) {
      throw new AnalyticsConfigurationException("maxDashboardsPerTenant must be greater than zero");
    }

    auto plan = toLower(defaultPlan);
    if (plan != "standard" && plan != "premium") {
      throw new AnalyticsConfigurationException("defaultPlan must be 'standard' or 'premium'");
    }

    if (datasphereIntegrationEnabled && datasphereEndpoint.length == 0) {
      throw new AnalyticsConfigurationException(
        "datasphereEndpoint is required when SAP Datasphere integration is enabled");
    }
  }
}
