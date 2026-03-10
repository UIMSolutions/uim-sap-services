module uim.sap.integrationsuite.config;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class INTConfig : SAPConfig {
  string host = "0.0.0.0";
  ushort port = 8100;
  string basePath = "/api/is";
  string serviceName = "uim-is";
  string serviceVersion = "1.0.0";
  bool requireAuthToken = false;
  string authToken;
  string[string] customHeaders;

  void validate() {
    super.validate();

    if (port == 0) {
      throw new INTConfigurationException("Port must be greater than zero");
    }
    if (basePath.length == 0) {
      throw new INTConfigurationException("Base path cannot be empty");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new INTConfigurationException("Auth token required but not set");
    }
  }
}
