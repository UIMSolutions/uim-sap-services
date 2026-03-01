module uim.sap.agentry.config;

import std.string : startsWith;

import uim.sap.agentry.exceptions;

struct AgentryConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8089;
    string basePath = "/api/agentry";

    string serviceName = "uim-sap-agentry";
    string serviceVersion = "1.0.0";
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
