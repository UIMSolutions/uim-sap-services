module uim.sap.featureflags.config;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

class FFLConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8094;
    string basePath = "/api/ff";
    string serviceName = "uim-sap-ff";
    string serviceVersion = "1.0.0";
    bool requireAuthToken = false;
    string authToken;
    string[string] customHeaders;

    void validate() {
        if (port == 0) {
            throw new FFLConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0) {
            throw new FFLConfigurationException("Base path cannot be empty");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new FFLConfigurationException("Auth token required but not set");
        }
    }
}
