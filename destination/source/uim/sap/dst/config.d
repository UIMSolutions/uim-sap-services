module uim.sap.dst.config;

import uim.sap.dst;

mixin(ShowModule!());

@safe:

class DSTConfig : SAPConfig {
  mixin(SAPConfigTemplate!DSTConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network settings
    basePath(initData.getString("basePath", "/api/destination"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8104));

    // Service settings
    serviceName(initData.getString("serviceName", "uim-dst"));
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

    if (runtime.length == 0) {
      throw new DSTConfigurationException("Runtime cannot be empty");
    }
  }
}
