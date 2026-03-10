module uim.sap.ctm.config;

import std.string : startsWith;

import uim.sap.ctm.exceptions;

struct CTMConfig : SAPConfig {
  mixin(SAPConfigTemplate!HTMRepoConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    return true;
  }

  ushort port = 8100;
  string basePath = "/api/cloud-transport";

  string serviceName = "uim-ctm";
  string serviceVersion = "1.0.0";
  string runtime = "cloud-foundry";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  void validate() const {
    super.validate();

    if (host.length == 0)
      throw new CTMConfigurationException("Host cannot be empty");
    if (port == 0)
      throw new CTMConfigurationException("Port must be greater than zero");
    if (basePath.length == 0 || !basePath.startsWith("/"))
      throw new CTMConfigurationException("Base path must start with '/'");
    if (serviceName.length == 0)
      throw new CTMConfigurationException("Service name cannot be empty");
    if (runtime.length == 0)
      throw new CTMConfigurationException("Runtime cannot be empty");
    if (requireAuthToken && authToken.length == 0)
      throw new CTMConfigurationException("Auth token required when token auth is enabled");
  }
}
