module uim.sap.cmg.config;


import uim.sap.cmg;

mixin(ShowModule!());

@safe:


struct CMGConfig {
    string host = "0.0.0.0";
    ushort port = 8095;
    string basePath = "/api/cmg";

    string serviceName = "uim-sap-cmg";
    string serviceVersion = "1.0.0";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) throw new CMGConfigurationException("Host cannot be empty");
        if (port == 0) throw new CMGConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/")) throw new CMGConfigurationException("Base path must start with '/'");
        if (serviceName.length == 0) throw new CMGConfigurationException("Service name cannot be empty");
        if (requireAuthToken && authToken.length == 0) throw new CMGConfigurationException("Auth token required when token auth is enabled");
    }
}
