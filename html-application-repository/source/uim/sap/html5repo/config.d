/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.har.config;

import uim.sap.har;

class HARConfig : SAPConfig {
  mixin(SAPConfigTemplate!HARConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8094));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/html5-repo"));
    serviceName(initData.getString("serviceName", "uim-html5-app-repo"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  string dataDirectory = "/tmp/uim-html5-repo-data";
  string defaultTenant = "provider";
  string defaultSpace = "dev";

  bool requireManagementAuth = false;
  string managementAuthToken;

  bool allowPublicCrossSpace = true;
  int cacheTtlSeconds = 120;
  long maxUploadBytes = 52_428_800L;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (host.length == 0)
      throw new HARConfigurationException("Host cannot be empty");
    if (port == 0)
      throw new HARConfigurationException("Port must be greater than zero");
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new HARConfigurationException("Base path must start with '/'");
    }
    if (serviceName.length == 0)
      throw new HARConfigurationException("Service name cannot be empty");
    if (dataDirectory.length == 0)
      throw new HARConfigurationException("Data directory cannot be empty");
    if (defaultTenant.length == 0)
      throw new HARConfigurationException("Default tenant cannot be empty");
    if (defaultSpace.length == 0)
      throw new HARConfigurationException("Default space cannot be empty");
    if (cacheTtlSeconds < 0)
      throw new HARConfigurationException("Cache TTL must be >= 0");
    if (maxUploadBytes < 1)
      throw new HARConfigurationException("maxUploadBytes must be positive");
    if (requireManagementAuth && managementAuthToken.length == 0) {
      throw new HARConfigurationException(
        "Management auth token is required when management auth is enabled"
      );
    }
  }
}
