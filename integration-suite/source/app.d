module app;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
  void main() {
    ISConfig config = new ISConfig;
    config.host = envOr("IS_HOST", "0.0.0.0");
    config.port = readPort(envOr("IS_PORT", "8100"), 8100);
    config.basePath = envOr("IS_BASE_PATH", "/api/is");
    config.serviceName = envOr("IS_SERVICE_NAME", "uim-sap-is");
    config.serviceVersion = envOr("IS_SERVICE_VERSION", UIM_IS_VERSION);

    auto token = envOr("IS_AUTH_TOKEN", "");
    if (token.length > 0) {
      config.requireAuthToken = true;
      config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new ISService(config);
    auto server = new ISServer(service);

    writeln("Starting Integration Suite service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
  }
}
