module uim.sap.agentry.config;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

class AgentryConfig : SAPConfig {
  mixin(SAPConfigTemplate!AgentryConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    serviceName(initData.getString("serviceName", "uim-agentry"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));
    host(initData.getString("host", "0.0.0.0"));

    return true;
  }

  ushort port = 8089;
  string basePath = "/api/agentry";

  string defaultBackendSystem = "s4-primary";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (defaultBackendSystem.length == 0) {
      throw new AgentryConfigurationException("Default backend system cannot be empty");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new AgentryConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
