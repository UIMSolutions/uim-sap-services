module uim.sap.sdi.config;

import std.string : startsWith;

import uim.sap.sdi.exceptions;

struct SDIConfig {
    string host = "0.0.0.0";
    ushort port = 8096;
    string basePath = "/api/sitedirectory";

    string serviceName = "uim-sap-sdi";
    string serviceVersion = "1.0.0";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) throw new SDIConfigurationException("Host cannot be empty");
        if (port == 0) throw new SDIConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/")) throw new SDIConfigurationException("Base path must start with '/'");
        if (serviceName.length == 0) throw new SDIConfigurationException("Service name cannot be empty");
        if (requireAuthToken && authToken.length == 0) throw new SDIConfigurationException("Auth token required when token auth is enabled");
    }
}
