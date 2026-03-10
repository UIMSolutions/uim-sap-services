module uim.sap.cag.config;

import std.string : startsWith;

import uim.sap.cag.exceptions;

struct CAGConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8096;
    string basePath = "/api/content-agent";

    string serviceName = "uim-content-agent";
    string serviceVersion = "1.0.0";
    string runtime = "cloud-foundry";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) throw new CAGConfigurationException("Host cannot be empty");
        if (port == 0) throw new CAGConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new CAGConfigurationException("Base path must start with '/'");
        }
        if (serviceName.length == 0) throw new CAGConfigurationException("Service name cannot be empty");
        if (runtime.length == 0) throw new CAGConfigurationException("Runtime cannot be empty");
        if (requireAuthToken && authToken.length == 0) {
            throw new CAGConfigurationException("Auth token required when token auth is enabled");
        }
    }
}
