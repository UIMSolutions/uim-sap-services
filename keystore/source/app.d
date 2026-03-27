module app;

import uim.sap.kst;
version (unittest) {
} else {
  void main() {
    KSTConfig config = new KSTConfig();
    config.host = envOr("KST_HOST", "0.0.0.0");
    config.port = readPort(envOr("KST_PORT", "8087"), 8087);
    config.basePath = envOr("KST_BASE_PATH", "/api/kst");
    config.serviceName = envOr("KST_SERVICE_NAME", "uim-kst");
    config.serviceVersion = envOr("KST_SERVICE_VERSION", UIM_KST_VERSION);
    config.masterKey = envOr("KST_MASTER_KEY", "uim-kst-dev-master-key");
    config.enableClientCertAuth = envOr("KST_ENABLE_CLIENT_CERT_AUTH", "false") == "true";

    auto maxKs = envOr("KST_MAX_KEYSTORES", "0");
    config.maxKeystores = readSize(maxKs, 0);

    auto token = envOr("KST_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken(true);
        config.authToken(token);
    }

    config.customHeader("X-Service", config.serviceName);
    config.customHeader("X-Version", config.serviceVersion);

    auto service = new KSTService(config);
    auto server = new KSTServer(service);

    writeln("Starting Keystore service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
}
