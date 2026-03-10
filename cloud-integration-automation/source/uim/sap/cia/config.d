module uim.sap.cia.config;

import std.string : startsWith;

import uim.sap.cia.exceptions;

/// Configuration for the Cloud Integration Automation service
struct CIAConfig : SAPConfig {
  mixin(SAPConfigTemplate!CIAConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    return true;
  }
    ushort port = 8098;
    string basePath = "/api/cloud-integration-automation";

    string serviceName    = "uim-cloud-integration-automation";
    string serviceVersion = "1.0.0";
    string runtime        = "cloud-foundry";

    bool   requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0)
            throw new CIAConfigurationException("Host cannot be empty");
        if (port == 0)
            throw new CIAConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/"))
            throw new CIAConfigurationException("Base path must start with '/'");
        if (serviceName.length == 0)
            throw new CIAConfigurationException("Service name cannot be empty");
        if (runtime.length == 0)
            throw new CIAConfigurationException("Runtime cannot be empty");
        if (requireAuthToken && authToken.length == 0)
            throw new CIAConfigurationException("Auth token required when token auth is enabled");
    }
}
