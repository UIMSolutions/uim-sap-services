module app;

import uim.sap.pdm;

void main() {
    PDMConfig config;
    config.host = envOr("PDM_HOST", "0.0.0.0");
    config.port = readPort(envOr("PDM_PORT", "8092"), 8092);
    config.basePath = envOr("PDM_BASE_PATH", "/api/pdm");
    config.serviceName = envOr("PDM_SERVICE_NAME", "uim-pdm");
    config.serviceVersion = envOr("PDM_SERVICE_VERSION", UIM_PDM_VERSION);

    config.maxSubjectsPerTenant = readSize(envOr("PDM_MAX_SUBJECTS_PER_TENANT", "100000"), 100_000);
    config.maxRequestsPerTenant = readSize(envOr("PDM_MAX_REQUESTS_PER_TENANT", "10000"), 10_000);
    config.maxRecordsPerSubject = readSize(envOr("PDM_MAX_RECORDS_PER_SUBJECT", "500"), 500);
    config.requestTimeoutSecs = readSize(envOr("PDM_REQUEST_TIMEOUT_SECS", "86400"), 86_400);
    config.defaultTenantId = envOr("PDM_DEFAULT_TENANT_ID", "default");
    config.multitenancy = envOr("PDM_MULTITENANCY", "true") == "true";

    auto token = envOr("PDM_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new PDMService(config);
    auto server = new PDMServer(service);

    writeln("Starting Personal Data Manager on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    writeln("Multitenancy: ", config.multitenancy);
    server.run();
}
