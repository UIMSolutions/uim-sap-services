module uim.sap.integrationsuite.config;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class INTConfig : SAPConfig {
  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8100));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/is"));
    serviceName(initData.getString("serviceName", "uim-is"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  bool requireAuthToken = false;
  string authToken;
  string[string] customHeaders;

  override void validate() {
    super.validate();

    if (requireAuthToken && authToken.length == 0) {
      throw new INTConfigurationException("Auth token required but not set");
    }
  }
}
