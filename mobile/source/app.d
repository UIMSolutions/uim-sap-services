module app;

import uim.sap.mob;

void main() {
    MOBConfig config = new MOBConfig();
    config.host = envOr("MOB_HOST", "0.0.0.0");
    config.port = readPort(envOr("MOB_PORT", "8089"), 8089);
    config.basePath = envOr("MOB_BASE_PATH", "/api/mob");
    config.serviceName = envOr("MOB_SERVICE_NAME", "uim-mob");
    config.serviceVersion = envOr("MOB_SERVICE_VERSION", UIM_MOB_VERSION);

    config.maxApplications = readSize(envOr("MOB_MAX_APPLICATIONS", "500"), 500);
    config.maxVersionsPerApp = readSize(envOr("MOB_MAX_VERSIONS_PER_APP", "100"), 100);
    config.maxUsersPerApp = readSize(envOr("MOB_MAX_USERS_PER_APP", "10000"), 10_000);
    config.maxNotificationsPerApp = readSize(envOr("MOB_MAX_NOTIFICATIONS_PER_APP", "5000"), 5000);
    config.defaultSyncIntervalSecs = readSize(envOr("MOB_DEFAULT_SYNC_INTERVAL", "300"), 300);

    auto token = envOr("MOB_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken(true;)
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new MOBService(config);
    auto server = new MOBServer(service);

    writeln("Starting Mobile Services on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
}
