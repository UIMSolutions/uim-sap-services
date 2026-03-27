module app;

import std.stdio : writeln;

import uim.sap.usagedatamanagement;

mixin(ShowModule!());

@safe:
version (unittest) {
} else {
  void main() {
  UDMConfig config = new UDMConfig();
  config.host = envOr("UDM_HOST", "0.0.0.0");
  config.port = readPort(envOr("UDM_PORT", "8109"), 8109);
  config.basePath = envOr("UDM_BASE_PATH", "/api/usage-data-management");
  config.serviceName = envOr("UDM_SERVICE_NAME", "uim-usage-data-management");
  config.serviceVersion = envOr("UDM_SERVICE_VERSION", UIM_USAGE_DATA_MANAGEMENT_VERSION);

  auto token = envOr("UDM_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true);
    config.authToken(token);
  }

  config.customHeader("X-Service", config.serviceName);
  config.customHeader("X-Version", config.serviceVersion);

  auto service = new UDMService(config);
  auto server = new UDMServer(service);

  writeln("Starting Usage Data Management service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);

  server.run();
}
