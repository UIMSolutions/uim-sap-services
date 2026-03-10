module uim.sap.atp.config;

import std.string : startsWith;

import uim.sap.atp.exceptions;

/** 
  * Configuration class for the Automation Pilot (ATP) service.
  * Contains all configurable parameters with validation logic.
  *
  * Example usage:
  * var config = new ATPConfig();
  * config.host = "localhost";
  * config.port = 8097;
  * config.basePath = "/api/automation-pilot";
  * config.aiProvider = "mock-genai";
  * config.requireAuthToken = false;
  * config.authToken = "";
  * config.customHeaders = ["Header1": "Value1", "Header2": "Value2"];
  * config.validate();
  *
  * The configuration can also be initialized from a JSON object:
  *
  * Fields:
  * - host: The hostname or IP address to bind the service (default: "0.0.0.0")
  * - port: The port number to bind the service (default: 8097)
  * - basePath: The base path for the API endpoints (default: "/api/automation-pilot")
  * - serviceName: The name of the service (default: "uim-atp")
  * - serviceVersion: The version of the service (default: "1.0.0")
  * - aiProvider: The AI provider to use (default: "mock-genai")
  * - requireAuthToken: Whether an auth token is required (default: false)
  * - authToken: The auth token to use if required
  * - customHeaders: Custom headers to include in requests
  * The validate() method checks for required fields and valid values, throwing an ATPConfigurationException if any issues are found.
  */
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
