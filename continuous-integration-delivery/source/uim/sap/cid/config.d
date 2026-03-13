module uim.sap.cid.config;

import std.string : startsWith;

import uim.sap.cid.exceptions;

class CIDConfig : SAPConfig {
  mixin(SAPConfigTemplate!CIDConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    port(cast(ushort)initData.getInteger("port", 8102));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/cicd"));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-cid"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBool("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  string runtime = "cloud-foundry";

  override void validate() const {
    super.validate();

    if (runtime.length == 0)
      throw new CIDConfigurationException("Runtime cannot be empty");
  }
}
