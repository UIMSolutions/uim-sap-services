module uim.sap.ctm.config;

import uim.sap.ctm;

mixin(ShowModule!());

@safe:

class CTMConfig : SAPConfig {
  mixin(SAPConfigTemplate!HTMRepoConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    basePath(initData.getString("basePath", "/api/cloud-transport"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8100));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-ctm"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  string runtime = "cloud-foundry";

  override void validate() const {
    super.validate();

    if (runtime.length == 0) {
      throw new CTMConfigurationException("Runtime cannot be empty");
    }
  }
}
