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

    void validate() const {
        if (host.length == 0) {
            throw new AgentryConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new AgentryConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new AgentryConfigurationException("Base path must start with '/'");
        }
        if (serviceName.length == 0) {
            throw new AgentryConfigurationException("Service name cannot be empty");
        }
        if (defaultBackendSystem.length == 0) {
            throw new AgentryConfigurationException("Default backend system cannot be empty");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new AgentryConfigurationException("Auth token required when token auth is enabled");
        }
    }
}
