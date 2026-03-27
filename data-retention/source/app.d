module app;

import std.stdio : writeln;

import uim.sap.dataretention;

mixin(ShowModule!());

@safe:
version (unittest) {
} else {
  void main() {
  DRMConfig config = new DRMConfig();
  config.host = envOr("DRM_HOST", "0.0.0.0");
  config.port = readPort(envOr("DRM_PORT", "8110"), 8110);
  config.basePath = envOr("DRM_BASE_PATH", "/api/data-retention");
  config.serviceName = envOr("DRM_SERVICE_NAME", "uim-data-retention");
  config.serviceVersion = envOr("DRM_SERVICE_VERSION", UIM_DATA_RETENTION_VERSION);

  auto token = envOr("DRM_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true);
    config.authToken(token);
  }

  config.customHeader("X-Service", config.serviceName);
  config.customHeader("X-Version", config.serviceVersion);

  auto service = new DRMService(config);
  auto server = new DRMServer(service);

  writeln("Starting Data Retention service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);

  server.run();
}
