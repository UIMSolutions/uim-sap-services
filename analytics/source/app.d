/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.analytics;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
  void main() {
    AnalyticsConfig config = new AnalyticsConfig();
    config.host = envOr("ANALYTICS_HOST", "0.0.0.0");
    config.port = readPort(envOr("ANALYTICS_PORT", "8090"), 8090);
    config.basePath = envOr("ANALYTICS_BASE_PATH", "/api/analytics");
    config.serviceName = envOr("ANALYTICS_SERVICE_NAME", "uim-analytics");
    config.serviceVersion = envOr("ANALYTICS_SERVICE_VERSION", UIM_ANALYTICS_VERSION);
    config.maxStoriesPerTenant = readInt(envOr("ANALYTICS_MAX_STORIES", "1000"), 1000);
    config.maxDashboardsPerTenant = readInt(envOr("ANALYTICS_MAX_DASHBOARDS", "500"), 500);
    config.maxDatasetsPerTenant = readInt(envOr("ANALYTICS_MAX_DATASETS", "200"), 200);
    config.maxModelsPerTenant = readInt(envOr("ANALYTICS_MAX_MODELS", "100"), 100);
    config.maxConnectionsPerTenant = readInt(envOr("ANALYTICS_MAX_CONNECTIONS", "50"), 50);
    config.maxUsersPerTenant = readInt(envOr("ANALYTICS_MAX_USERS", "10000"), 10000);
    config.predictionTimeoutSeconds = readInt(envOr("ANALYTICS_PREDICTION_TIMEOUT", "300"), 300);
    config.defaultPlan = envOr("ANALYTICS_DEFAULT_PLAN", "standard");

    auto datasphereEndpoint = envOr("ANALYTICS_DATASPHERE_ENDPOINT", "");
    if (datasphereEndpoint.length > 0) {
      config.datasphereIntegrationEnabled = true;
      config.datasphereEndpoint = datasphereEndpoint;
    }

    auto mgmtToken = envOr("ANALYTICS_AUTH_TOKEN", "");
    if (mgmtToken.length > 0) {
      config.requireAuthToken(true);
      config.authToken = mgmtToken;
    }

    config.customHeader("X-Service", config.serviceName);
    config.customHeader("X-Version", config.serviceVersion);

    auto service = new AnalyticsService(config);
    auto server = new AnalyticsServer(service);

    writeln("Starting SAP Analytics Cloud service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
  }
}
