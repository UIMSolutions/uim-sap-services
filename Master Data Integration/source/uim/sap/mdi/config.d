module uim.sap.mdi.config;

import std.string : startsWith;

import uim.sap.mdi.exceptions;

struct MDIConfig {
    string host = "0.0.0.0";
    ushort port = 8092;
    string basePath = "/api/mdi";

    string serviceName = "uim-sap-mdi";
    string serviceVersion = "1.0.0";
    string defaultObjectType = "business_partner";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) throw new MDIConfigurationException("Host cannot be empty");
        if (port == 0) throw new MDIConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/")) throw new MDIConfigurationException("Base path must start with '/'");
        if (serviceName.length == 0) throw new MDIConfigurationException("Service name cannot be empty");
        if (defaultObjectType.length == 0) throw new MDIConfigurationException("Default object type cannot be empty");
        if (requireAuthToken && authToken.length == 0) throw new MDIConfigurationException("Auth token required when token auth is enabled");
    }
}
