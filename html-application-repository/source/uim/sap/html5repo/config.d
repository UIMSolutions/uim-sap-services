/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.html5repo.config;

import uim.sap.html5repo;

struct HTMRepoConfig : SAPHostConfig {
  mixin(SAPConfigTemplate!HTMRepoConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    return true;
  }

    ushort port = 8094;
    string basePath = "/api/html5-repo";

    string serviceName = "uim-sap-html5-app-repo";
    string serviceVersion = "1.0.0";

    string dataDirectory = "/tmp/uim-html5-repo-data";
    string defaultTenant = "provider";
    string defaultSpace = "dev";

    bool requireManagementAuth = false;
    string managementAuthToken;

    bool allowPublicCrossSpace = true;
    int cacheTtlSeconds = 120;
    long maxUploadBytes = 52_428_800L;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) throw new HTMRepoConfigurationException("Host cannot be empty");
        if (port == 0) throw new HTMRepoConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new HTMRepoConfigurationException("Base path must start with '/'");
        }
        if (serviceName.length == 0) throw new HTMRepoConfigurationException("Service name cannot be empty");
        if (dataDirectory.length == 0) throw new HTMRepoConfigurationException("Data directory cannot be empty");
        if (defaultTenant.length == 0) throw new HTMRepoConfigurationException("Default tenant cannot be empty");
        if (defaultSpace.length == 0) throw new HTMRepoConfigurationException("Default space cannot be empty");
        if (cacheTtlSeconds < 0) throw new HTMRepoConfigurationException("Cache TTL must be >= 0");
        if (maxUploadBytes < 1) throw new HTMRepoConfigurationException("maxUploadBytes must be positive");
        if (requireManagementAuth && managementAuthToken.length == 0) {
            throw new HTMRepoConfigurationException(
                "Management auth token is required when management auth is enabled"
            );
        }
    }
}
