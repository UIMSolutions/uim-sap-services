module uim.sap.aem.config;

import uim.sap.aem;

mixin(ShowModule!());

@safe:
struct AEMConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8088;
    string basePath = "/api/aem";

    string serviceName = "uim-sap-aem";
    string serviceVersion = "1.0.0";
    string defaultMeshRegion = "eu10";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new AEMConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new AEMConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new AEMConfigurationException("Base path must start with '/'");
        }
        if (serviceName.length == 0) {
            throw new AEMConfigurationException("Service name cannot be empty");
        }
        if (defaultMeshRegion.length == 0) {
            throw new AEMConfigurationException("Default mesh region cannot be empty");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new AEMConfigurationException("Auth token required when token auth is enabled");
        }
    }
}
