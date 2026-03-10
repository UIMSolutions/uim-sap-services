module uim.sap.cre.config;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

struct CREConfig : SAPConfig {
  mixin(SAPConfigTemplate!(CREConfig));

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/cre"));
    serviceName(initData.getString("serviceName", "uim-cre"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  ushort port = 8086;

  bool requireAuthToken = false;
  string authToken;

  string masterKey = "uim-cre-dev-master-key";

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (host.length == 0) {
      throw new CREConfigurationException("Host cannot be empty");
    }
    if (port == 0) {
      throw new CREConfigurationException("Port must be greater than zero");
    }
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new CREConfigurationException("Base path must start with '/'");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new CREConfigurationException("Auth token required when token auth is enabled");
    }
    if (masterKey.length == 0) {
      throw new CREConfigurationException("Master key cannot be empty");
    }
  }
}
