module uim.sap.kym.config;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

struct KYMConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8088;
    string basePath = "/api/kym";

    string serviceName = "uim-kym";
    string serviceVersion = "1.0.0";

    bool requireAuthToken = false;
    string authToken;

    /// Maximum namespaces per runtime
    size_t maxNamespaces = 100;

    /// Maximum functions per namespace
    size_t maxFunctionsPerNamespace = 500;

    /// Maximum microservices per namespace
    size_t maxMicroservicesPerNamespace = 200;

    /// Maximum event subscriptions per namespace
    size_t maxSubscriptionsPerNamespace = 1000;

    /// Default function timeout in seconds
    size_t defaultFunctionTimeoutSecs = 30;

    /// Default replica count for microservices
    size_t defaultReplicas = 1;

    string[string] customHeaders;

    void validate() const {
        super.validate();

        if (host.length == 0)
            throw new KYMConfigurationException("Host cannot be empty");
        if (port == 0)
            throw new KYMConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/"))
            throw new KYMConfigurationException("Base path must start with '/'");
        if (requireAuthToken && authToken.length == 0)
            throw new KYMConfigurationException("Auth token required when token auth is enabled");
        if (maxNamespaces == 0)
            throw new KYMConfigurationException("maxNamespaces must be greater than zero");
    }
}
