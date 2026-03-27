module app;

import uim.sap.slm;
mixin(ShowModule!());

@safe:
version (unittest) {
} else {
  void main() {
  SLMConfig config = new SLMConfig();
  config.host = envOr("SLM_HOST", "0.0.0.0");
  config.port = readPort(envOr("SLM_PORT", "8120"), 8120);
  config.basePath = envOr("SLM_BASE_PATH", "/api/solution-lifecycle");
  config.serviceName = envOr("SLM_SERVICE_NAME", "uim-slm");
  config.serviceVersion = envOr("SLM_SERVICE_VERSION", UIM_SLM_VERSION);
  config.runtime = envOr("SLM_RUNTIME", "cloud-foundry");

  auto token = envOr("SLM_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true);
    config.authToken(token);
  }

  config.customHeader("X-Service", config.serviceName);
  config.customHeader("X-Version", config.serviceVersion);

  auto service = new SLMService(config);
  auto server = new SLMServer(service);

  writeln("Starting Solution Lifecycle Management service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
