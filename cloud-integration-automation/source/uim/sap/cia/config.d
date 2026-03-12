module uim.sap.cia.config;

import std.string : startsWith;

import uim.sap.cia.exceptions;

/// Configuration for the Cloud Integration Automation service
class CIAConfig : SAPConfig {
  mixin(SAPConfigTemplate!CIAConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8098));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/cloud-integration-automation"));
    serviceName(initData.getString("serviceName", "uim-cloud-integration-automation"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  string runtime = "cloud-foundry";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (runtime.length == 0) {
      throw new CIAConfigurationException("Runtime cannot be empty");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new CIAConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
