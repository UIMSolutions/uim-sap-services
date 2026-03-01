module uim.sap.isa.config;

import std.string : startsWith;

import uim.sap.isa.exceptions;

struct ISAConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8088;
    string basePath = "/api/situation-automation";

    string serviceName = "uim-sap-isa";
    string serviceVersion = "1.0.0";

    string defaultTenant = "default";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new ISAConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new ISAConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new ISAConfigurationException("Base path must start with '/'");
        }
        if (defaultTenant.length == 0) {
            throw new ISAConfigurationException("Default tenant cannot be empty");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new ISAConfigurationException("Auth token required when token auth is enabled");
        }
    }
}
