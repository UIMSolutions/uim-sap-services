module app;

import uim.sap.prm;

mixin(ShowModule!());

@safe:

void main() {
  PRMConfig config;
  config.host = envOr("PRM_HOST", "0.0.0.0");
  config.port = readPort(envOr("PRM_PORT", "8096"), 8096);
  config.basePath = envOr("PRM_BASE_PATH", "/api/prm");
  config.serviceName = envOr("PRM_SERVICE_NAME", "uim-prm");
  config.serviceVersion = envOr("PRM_SERVICE_VERSION", UIM_PRM_VERSION);
  config.defaultCapacityHours = readDouble(envOr("PRM_DEFAULT_CAPACITY_HOURS", "8"), 8);

  auto token = envOr("PRM_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true);
    config.authToken(token);
  }

  config.customHeader("X-Service", config.serviceName);
  config.customHeader("X-Version", config.serviceVersion);

  auto service = new PRMService(config);
  auto server = new PRMServer(service);

  writeln("Starting PRM service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
