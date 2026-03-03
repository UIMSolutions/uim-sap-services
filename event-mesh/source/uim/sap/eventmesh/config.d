module uim.sap.eventmesh.config;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EMConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8092;
    string basePath = "/api/em";
    string serviceName = "uim-sap-em";
    string serviceVersion = "1.0.0";
    bool requireAuthToken = false;
    string authToken;
    string[string] customHeaders;

    void validate() {
        if (port == 0) {
            throw new EMConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0) {
            throw new EMConfigurationException("Base path cannot be empty");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new EMConfigurationException("Auth token required but not set");
        }
    }
}
