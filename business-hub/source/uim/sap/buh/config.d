/**
 * Configuration for BUH service
 */
module uim.sap.buh.config;

import std.string : startsWith;

import uim.sap.buh.exceptions;

struct BUHConfig : SAPConfig, ISAPConfig {
    string host = "0.0.0.0";
    ushort port = 8083;
    string basePath = "/api/hub";

    string serviceName = "uim-sap-buh";
    string serviceVersion = "1.0.0";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new BUHConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new BUHConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new BUHConfigurationException("Base path must start with '/'");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new BUHConfigurationException("Auth token required when token auth is enabled");
        }
    }
}
