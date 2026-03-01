module uim.sap.mon.config;

import std.string : startsWith;

import uim.sap.mon.exceptions;

struct MONConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8090;
    string basePath = "/api/mon";

    string serviceName = "uim-sap-mon";
    string serviceVersion = "1.0.0";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new MONConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new MONConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new MONConfigurationException("Base path must start with '/'");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new MONConfigurationException("Auth token required when token auth is enabled");
        }
    }
}
