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

    port(cast(ushort)initData.getInteger("port", 8096));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/content-agent"));
    serviceName(initData.getString("serviceName", "uim-content-agent"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  string runtime = "cloud-foundry";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (host.length == 0)
      throw new CAGConfigurationException("Host cannot be empty");
    if (port == 0)
      throw new CAGConfigurationException("Port must be greater than zero");
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new CAGConfigurationException("Base path must start with '/'");
    }
    if (serviceName.length == 0)
      throw new CAGConfigurationException("Service name cannot be empty");
    if (runtime.length == 0)
      throw new CAGConfigurationException("Runtime cannot be empty");
    if (requireAuthToken && authToken.length == 0) {
      throw new CAGConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
