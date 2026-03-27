module app;

import uim.sap.ctm;
mixin(ShowModule!());

@safe:
version (unittest) {
} else {
  void main() {
  CTMConfig config = new CTMConfig();
  config.host = envOr("CTM_HOST", "0.0.0.0");
  config.port = readPort(envOr("CTM_PORT", "8100"), 8100);
  config.basePath = envOr("CTM_BASE_PATH", "/api/cloud-transport");
  config.serviceName = envOr("CTM_SERVICE_NAME", "uim-ctm");
  config.serviceVersion = envOr("CTM_SERVICE_VERSION", UIM_CTM_VERSION);
  config.runtime = envOr("CTM_RUNTIME", "cloud-foundry");

  auto token = envOr("CTM_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true);
    config.authToken(token);
  }

  config.customHeader("X-Service", config.serviceName);
  config.customHeader("X-Version", config.serviceVersion);

  auto service = new CTMService(config);
  auto server = new CTMServer(service);

  writeln("Starting Cloud Transport Management service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
