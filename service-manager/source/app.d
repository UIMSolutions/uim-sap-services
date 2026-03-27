module app;

import std.stdio : writeln;

import uim.sap.servicemanager;

mixin(ShowModule!());

@safe:
version (unittest) {
} else {
  void main() {
  SVMConfig config = new SVMConfig();
  config.host = envOr("SVM_HOST", "0.0.0.0");
  config.port = readPort(envOr("SVM_PORT", "8111"), 8111);
  config.basePath = envOr("SVM_BASE_PATH", "/api/service-manager");
  config.serviceName = envOr("SVM_SERVICE_NAME", "uim-service-manager");
  config.serviceVersion = envOr("SVM_SERVICE_VERSION", UIM_SERVICE_MANAGER_VERSION);

  auto token = envOr("SVM_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true);
    config.authToken(token);
  }

  config.customHeader("X-Service", config.serviceName);
  config.customHeader("X-Version", config.serviceVersion);

  auto service = new SVMService(config);
  auto server = new SVMServer(service);

  writeln("Starting Service Manager service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);

  server.run();
}
