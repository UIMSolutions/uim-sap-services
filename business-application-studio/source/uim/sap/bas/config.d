module uim.sap.bas.config;

import uim.sap.bas;

mixin(ShowModule!());

@safe:

struct BASConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8088;
    string basePath = "/api/business-application-studio";

    string serviceName = "uim-sap-bas";
    string serviceVersion = "1.0.0";
    string defaultRegion = "eu10";

    string[] regions = ["eu10", "us10", "ap10"];
    string[] hyperscalers = ["aws", "azure", "gcp"];

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) throw new BASConfigurationException("Host cannot be empty");
        if (port == 0) throw new BASConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/")) throw new BASConfigurationException("Base path must start with '/'");
        if (serviceName.length == 0) throw new BASConfigurationException("Service name cannot be empty");
        if (defaultRegion.length == 0) throw new BASConfigurationException("Default region cannot be empty");
        if (requireAuthToken && authToken.length == 0) throw new BASConfigurationException("Auth token required when token auth is enabled");
    }
}
