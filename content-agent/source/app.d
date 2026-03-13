module app;

import uim.sap.cag;

mixin(ShowModule!());

@safe:

void main() {
  CAGConfig config = new CAGConfig();
  config.host = envOr("CAG_HOST", "0.0.0.0");
  config.port = readPort(envOr("CAG_PORT", "8096"), 8096);
  config.basePath = envOr("CAG_BASE_PATH", "/api/content-agent");
  config.serviceName = envOr("CAG_SERVICE_NAME", "uim-content-agent");
  config.serviceVersion = envOr("CAG_SERVICE_VERSION", UIM_CAG_VERSION);
  config.runtime = envOr("CAG_RUNTIME", "cloud-foundry");

  auto token = envOr("CAG_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true;)
    config.authToken = token;
  }

  config.customHeaders["X-Service"] = config.serviceName;
  config.customHeaders["X-Version"] = config.serviceVersion;

  auto service = new CAGService(config);
  auto server = new CAGServer(service);

  writeln("Starting Content Agent service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
