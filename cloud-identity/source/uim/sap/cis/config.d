module uim.sap.cis.config;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

struct CISConfig {
    string host = "0.0.0.0";
    ushort port = 8088;
    string basePath = "/api/cis";

    string serviceName = "uim-sap-cis";
    string serviceVersion = "1.0.0";
    string defaultAuthMethod = "form";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new CISConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new CISConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new CISConfigurationException("Base path must start with '/'");
        }
        if (serviceName.length == 0) {
            throw new CISConfigurationException("Service name cannot be empty");
        }
        if (defaultAuthMethod.length == 0) {
            throw new CISConfigurationException("Default auth method cannot be empty");
        }
        auto normalized = toLower(defaultAuthMethod);
        if (normalized != "form" && normalized != "spnego" && normalized != "social" && normalized != "2fa") {
            throw new CISConfigurationException("Unsupported default auth method");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new CISConfigurationException("Auth token required when token auth is enabled");
        }
    }
}
