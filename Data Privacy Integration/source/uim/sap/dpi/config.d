module uim.sap.dpi.config;

import std.string : startsWith;

import uim.sap.dpi.exceptions;

struct DPIConfig {
    string host = "0.0.0.0";
    ushort port = 8093;
    string basePath = "/api/dpi";

    string serviceName = "uim-sap-dpi";
    string serviceVersion = "1.0.0";
    int defaultRetentionDays = 365;

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) throw new DPIConfigurationException("Host cannot be empty");
        if (port == 0) throw new DPIConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/")) throw new DPIConfigurationException("Base path must start with '/'");
        if (serviceName.length == 0) throw new DPIConfigurationException("Service name cannot be empty");
        if (defaultRetentionDays <= 0) throw new DPIConfigurationException("Default retention days must be greater than zero");
        if (requireAuthToken && authToken.length == 0) throw new DPIConfigurationException("Auth token required when token auth is enabled");
    }
}
