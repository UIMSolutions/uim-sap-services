module uim.sap.cid.config;

import std.string : startsWith;

import uim.sap.cid.exceptions;

struct CIDConfig : SAPConfig, ISAPConfig {
    string host = "0.0.0.0";
    ushort port = 8102;
    string basePath = "/api/cicd";

    string serviceName    = "uim-sap-cid";
    string serviceVersion = "1.0.0";
    string runtime        = "cloud-foundry";

    bool   requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0)
            throw new CIDConfigurationException("Host cannot be empty");
        if (port == 0)
            throw new CIDConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/"))
            throw new CIDConfigurationException("Base path must start with '/'");
        if (serviceName.length == 0)
            throw new CIDConfigurationException("Service name cannot be empty");
        if (runtime.length == 0)
            throw new CIDConfigurationException("Runtime cannot be empty");
        if (requireAuthToken && authToken.length == 0)
            throw new CIDConfigurationException("Auth token required when token auth is enabled");
    }
}
