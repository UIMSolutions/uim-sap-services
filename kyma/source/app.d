module app;

import uim.sap.kym;

void main() {
    KYMConfig config = new KYMConfig();
    config.host = envOr("KYM_HOST", "0.0.0.0");
    config.port = readPort(envOr("KYM_PORT", "8088"), 8088);
    config.basePath = envOr("KYM_BASE_PATH", "/api/kym");
    config.serviceName = envOr("KYM_SERVICE_NAME", "uim-kym");
    config.serviceVersion = envOr("KYM_SERVICE_VERSION", UIM_KYM_VERSION);

    config.maxNamespaces = readSize(envOr("KYM_MAX_NAMESPACES", "100"), 100);
    config.maxFunctionsPerNamespace = readSize(envOr("KYM_MAX_FUNCTIONS_PER_NS", "500"), 500);
    config.maxMicroservicesPerNamespace = readSize(envOr("KYM_MAX_MICROSERVICES_PER_NS", "200"), 200);
    config.maxSubscriptionsPerNamespace = readSize(envOr("KYM_MAX_SUBSCRIPTIONS_PER_NS", "1000"), 1000);
    config.defaultFunctionTimeoutSecs = readSize(envOr("KYM_DEFAULT_FUNCTION_TIMEOUT", "30"), 30);
    config.defaultReplicas = readSize(envOr("KYM_DEFAULT_REPLICAS", "1"), 1);

    auto token = envOr("KYM_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken(true);
        config.authToken(token);
    }

    config.customHeader("X-Service", config.serviceName);
    config.customHeader("X-Version", config.serviceVersion);

    auto service = new KYMService(config);
    auto server = new KYMServer(service);

    writeln("Starting Kyma Runtime service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
}
