module app;

import uim.sap.pre;

void main() {
    PREConfig config = new PREConfig();
    config.host = envOr("PRE_HOST", "0.0.0.0");
    config.port = readPort(envOr("PRE_PORT", "8093"), 8093);
    config.basePath = envOr("PRE_BASE_PATH", "/api/pre");
    config.serviceName = envOr("PRE_SERVICE_NAME", "uim-pre");
    config.serviceVersion = envOr("PRE_SERVICE_VERSION", UIM_PRE_VERSION);

    config.maxItemsPerTenant = readSize(envOr("PRE_MAX_ITEMS_PER_TENANT", "500000"), 500_000);
    config.maxUsersPerTenant = readSize(envOr("PRE_MAX_USERS_PER_TENANT", "1000000"), 1_000_000);
    config.maxInteractionsPerUser = readSize(envOr("PRE_MAX_INTERACTIONS_PER_USER", "10000"), 10_000);
    config.maxModelsPerTenant = readSize(envOr("PRE_MAX_MODELS_PER_TENANT", "50"), 50);
    config.maxScenariosPerTenant = readSize(envOr("PRE_MAX_SCENARIOS_PER_TENANT", "100"), 100);
    config.defaultRecommendationLimit = readSize(envOr("PRE_DEFAULT_LIMIT", "10"), 10);
    config.maxRecommendationLimit = readSize(envOr("PRE_MAX_LIMIT", "100"), 100);
    config.defaultTenantId = envOr("PRE_DEFAULT_TENANT_ID", "default");
    config.multitenancy = envOr("PRE_MULTITENANCY", "true") == "true";

    auto token = envOr("PRE_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken(true);
        config.authToken(token);
    }

    config.customHeader("X-Service", config.serviceName);
    config.customHeader("X-Version", config.serviceVersion);

    auto service = new PREService(config);
    auto server = new PREServer(service);

    writeln("Starting Personalized Recommendation Service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    writeln("Multitenancy: ", config.multitenancy);
    server.run();
}
