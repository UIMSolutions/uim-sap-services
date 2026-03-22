module uim.sap.cag.config;

import uim.sap.cag;

mixin(ShowModule!());

@safe:

class CAGConfig : SAPConfig {
  mixin(SAPConfigTemplate!CAGConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Service runtime settings
    basePath(initData.getString("basePath", "/api/content-agent"));
    port(cast(ushort)initData.getInteger("port", 8096));
    host(initData.getString("host", "0.0.0.0"));

    // Service identity settings
    serviceName(initData.getString("serviceName", "uim-content-agent"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication settings
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  string runtime = "cloud-foundry";

  string[string] customHeaders;

  override void validate() {
    super.validate();

    if (runtime.length == 0) {
      throw new CAGConfigurationException("Runtime cannot be empty");
    }
  }
}
