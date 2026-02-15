/**
 * Configuration for CLF service
 */
module uim.sap.clf.config;

import uim.sap.clf;

mixin(ShowModule!());

@safe:

struct CLFConfig {
    string host = "0.0.0.0";
    ushort port = 8082;
    string basePath = "/api/cf";

    string serviceName = "uim-sap-clf";
    string serviceVersion = "1.0.0";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new CLFConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new CLFConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new CLFConfigurationException("Base path must start with '/'");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new CLFConfigurationException("Auth token required when token auth is enabled");
        }
    }
}
