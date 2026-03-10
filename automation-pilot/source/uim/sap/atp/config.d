module uim.sap.atp.config;

import std.string : startsWith;

import uim.sap.atp.exceptions;

class ATPConfig : SAPConfig {
  mixin(SAPConfigTemplate!AgentryConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    serviceName(initData.getString("serviceName", "uim-atp"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }
    ushort port = 8097;
    string basePath = "/api/automation-pilot";

    string aiProvider = "mock-genai";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) throw new ATPConfigurationException("Host cannot be empty");
        if (port == 0) throw new ATPConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/")) throw new ATPConfigurationException("Base path must start with '/'");
        if (serviceName.length == 0) throw new ATPConfigurationException("Service name cannot be empty");
        if (aiProvider.length == 0) throw new ATPConfigurationException("AI provider cannot be empty");
        if (requireAuthToken && authToken.length == 0) throw new ATPConfigurationException("Auth token required when token auth is enabled");
    }
}
