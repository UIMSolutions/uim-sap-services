module uim.sap.cid.config;

import std.string : startsWith;

import uim.sap.cid.exceptions;

class CIDConfig : SAPConfig {
  mixin(SAPConfigTemplate!CIDConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network settings 
    basePath(initData.getString("basePath", "/api/cicd"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8102));

    // Service settings
    serviceName(initData.getString("serviceName", "uim-cid"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication settings
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  string runtime = "cloud-foundry";

  override void validate() {
    super.validate();

    if (runtime.length == 0)
      throw new CIDConfigurationException("Runtime cannot be empty");
  }
}
