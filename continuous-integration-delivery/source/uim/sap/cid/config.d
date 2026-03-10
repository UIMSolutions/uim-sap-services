module uim.sap.cid.config;

import std.string : startsWith;

import uim.sap.cid.exceptions;

struct CIDConfig : SAPConfig {
  mixin(SAPConfigTemplate!CIDConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/cicd"));
    serviceName(initData.getString("serviceName", "uim-cid"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  ushort port = 8102;
  string runtime = "cloud-foundry";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  void validate() const {
    super.validate();

    if (host.length == 0)
      throw new CIDConfigurationException("Host cannot be empty");
    if (port == 0)
      throw new CIDConfigurationException("Port must be greater than zero");
    if (basePath.length == 0 || !basePath.startsWith("/"))
      throw new CIDConfigurationException("Base path must start with '/'");
    if (serviceName.length == 0)
      throw new CIDConfigurationException("Service name cannot be empty");
    if (runtime.length == 0)
      throw new CIDConfigurationException("Runtime cannot be empty");
    if (requireAuthToken && authToken.length == 0)
      throw new CIDConfigurationException("Auth token required when token auth is enabled");
  }
}
