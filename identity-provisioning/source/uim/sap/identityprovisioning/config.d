module uim.sap.identityprovisioning.config;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

class IPConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8095;
    string basePath = "/api/ip";
    string serviceName = "uim-sap-ip";
    string serviceVersion = "1.0.0";
    bool requireAuthToken = false;
    string authToken;
    string[string] customHeaders;

    void validate() {
        if (port == 0) {
            throw new IPConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0) {
            throw new IPConfigurationException("Base path cannot be empty");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new IPConfigurationException("Auth token required but not set");
        }
    }
}
