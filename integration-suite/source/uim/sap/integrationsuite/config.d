module uim.sap.integrationsuite.config;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class INTConfig : SAPConfig {
  override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
      return false;
    }

    port(cast(ushort)initdata.getInteger("port", 8100));
    host(initdata.getString("host", "0.0.0.0"));
    basePath(initdata.getString("basePath", "/api/is"));
    serviceName(initdata.getString("serviceName", "uim-is"));
    serviceVersion(initdata.getString("serviceVersion", "1.0.0"));

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
