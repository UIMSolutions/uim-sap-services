module uim.sap.cps.config;

import std.string : startsWith;

import uim.sap.cps.exceptions;

struct CPSConfig : SAPConfig {
  mixin(SAPConfigTemplate!CPSConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/cps"));
    serviceName(initData.getString("serviceName", "uim-cps"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  ushort port = 8089;

  string defaultTheme = "sap_fiori_3";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  void validate() const {
    super.validate();

    if (host.length == 0)
      throw new CPSConfigurationException("Host cannot be empty");
    if (port == 0)
      throw new CPSConfigurationException("Port must be greater than zero");
    if (basePath.length == 0 || !basePath.startsWith("/"))
      throw new CPSConfigurationException("Base path must start with '/'");
    if (serviceName.length == 0)
      throw new CPSConfigurationException("Service name cannot be empty");
    if (defaultTheme.length == 0)
      throw new CPSConfigurationException("Default theme cannot be empty");
    if (requireAuthToken && authToken.length == 0)
      throw new CPSConfigurationException("Auth token required when token auth is enabled");
  }
}
