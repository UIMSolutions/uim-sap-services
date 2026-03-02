module uim.sap.dst.config;

import std.string : startsWith;

import uim.sap.dst.exceptions;

struct DSTConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8104;
    string basePath = "/api/destination";

    string serviceName    = "uim-sap-dst";
    string serviceVersion = "1.0.0";
    string runtime        = "cloud-foundry";

    bool   requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0)
            throw new DSTConfigurationException("Host cannot be empty");
        if (port == 0)
            throw new DSTConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/"))
            throw new DSTConfigurationException("Base path must start with '/'");
        if (serviceName.length == 0)
            throw new DSTConfigurationException("Service name cannot be empty");
        if (runtime.length == 0)
            throw new DSTConfigurationException("Runtime cannot be empty");
        if (requireAuthToken && authToken.length == 0)
            throw new DSTConfigurationException("Auth token required when token auth is enabled");
    }
}
