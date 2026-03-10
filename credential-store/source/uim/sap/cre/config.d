module uim.sap.cre.config;

import uim.sap.cre;

mixin(ShowModule!());

@safe:


struct CREConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8086;
    string basePath = "/api/cre";

    string serviceName = "uim-cre";
    string serviceVersion = "1.0.0";

    bool requireAuthToken = false;
    string authToken;

    string masterKey = "uim-cre-dev-master-key";

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new CREConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new CREConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new CREConfigurationException("Base path must start with '/'");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new CREConfigurationException("Auth token required when token auth is enabled");
        }
        if (masterKey.length == 0) {
            throw new CREConfigurationException("Master key cannot be empty");
        }
    }
}
