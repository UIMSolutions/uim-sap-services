module uim.sap.pre.config;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

struct PREConfig : SAPConfig {

    override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
       return false;
    }

    return true;
  }
    string host = "0.0.0.0";
    ushort port = 8093;
    string basePath = "/api/pre";

    string serviceName = "uim-pre";
    string serviceVersion = "1.0.0";

    bool requireAuthToken = false;
    string authToken;

    /// Maximum items per tenant
    size_t maxItemsPerTenant = 500_000;

    /// Maximum users per tenant
    size_t maxUsersPerTenant = 1_000_000;

    /// Maximum interactions stored per user
    size_t maxInteractionsPerUser = 10_000;

    /// Maximum models per tenant
    size_t maxModelsPerTenant = 50;

    /// Maximum scenarios per tenant
    size_t maxScenariosPerTenant = 100;

    /// Default number of recommendations returned
    size_t defaultRecommendationLimit = 10;

    /// Maximum number of recommendations per request
    size_t maxRecommendationLimit = 100;

    /// Default tenant ID for single-tenant mode
    string defaultTenantId = "default";

    /// Enable multitenancy
    bool multitenancy = true;

    string[string] customHeaders;

    override void validate() const {
        super.validate();

        if (host.length == 0)
            throw new PREConfigurationException("Host cannot be empty");
        if (port == 0)
            throw new PREConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/"))
            throw new PREConfigurationException("Base path must start with '/'");
        if (requireAuthToken && authToken.length == 0)
            throw new PREConfigurationException("Auth token required when token auth is enabled");
        if (maxItemsPerTenant == 0)
            throw new PREConfigurationException("maxItemsPerTenant must be greater than zero");
        if (defaultRecommendationLimit == 0 || defaultRecommendationLimit > maxRecommendationLimit)
            throw new PREConfigurationException("defaultRecommendationLimit must be between 1 and maxRecommendationLimit");
    }
}
