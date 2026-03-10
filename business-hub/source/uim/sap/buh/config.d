module uim.sap.buh.config;

import std.string : startsWith;

import uim.sap.buh.exceptions;

struct BUHConfig : SAPConfig {
  mixin(SAPConfigTemplate!BUHConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    serviceName(initData.getString("serviceName", "uim-buh"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  ushort port = 8083;
  string basePath = "/api/hub";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (host.length == 0) {
      throw new BUHConfigurationException("Host cannot be empty");
    }
    if (port == 0) {
      throw new BUHConfigurationException("Port must be greater than zero");
    }
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new BUHConfigurationException("Base path must start with '/'");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new BUHConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
