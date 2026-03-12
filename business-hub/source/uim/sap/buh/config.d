module uim.sap.buh.config;

import std.string : startsWith;

import uim.sap.buh.exceptions;

class BUHConfig : SAPConfig {
  mixin(SAPConfigTemplate!BUHConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8083));
    basePath(initData.getString("basePath", "/api/hub"));
    host(initData.getString("host", "0.0.0.0"));
    serviceName(initData.getString("serviceName", "uim-buh"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }


  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (requireAuthToken && authToken.length == 0) {
      throw new BUHConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
