module uim.sap.dqm.config;

import uim.sap.dqm;

mixin(ShowModule!());

@safe:

class DQMConfig : SAPConfig {
  mixin(SAPConfigTemplate!DQMConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8091));
    basePath(initData.getString("basePath", "/api/dqm"));
    serviceName(initData.getString("serviceName", "uim-dqm"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));
    defaultCountry(initData.getString("defaultCountry", "DE"));

    return true;
  }

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();
    
    if (host.length == 0)
      throw new DQMConfigurationException("Host cannot be empty");
    if (port == 0)
      throw new DQMConfigurationException("Port must be greater than zero");
    if (basePath.length == 0 || !basePath.startsWith("/"))
      throw new DQMConfigurationException("Base path must start with '/'");
    if (serviceName.length == 0)
      throw new DQMConfigurationException("Service name cannot be empty");
    if (defaultCountry.length == 0)
      throw new DQMConfigurationException("Default country cannot be empty");
    if (requireAuthToken && authToken.length == 0)
      throw new DQMConfigurationException("Auth token required when token auth is enabled");
  }
}
