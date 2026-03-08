module app;

import uim.sap.bas;

mixin(ShowModule!());

@safe:

void main() {
  BASConfig config;
  config.host = envOr("BAS_HOST", "0.0.0.0");
  config.port = readPort(envOr("BAS_PORT", "8088"), 8088);
  config.basePath = envOr("BAS_BASE_PATH", "/api/business-application-studio");
  config.serviceName = envOr("BAS_SERVICE_NAME", "uim-sap-bas");
  config.serviceVersion = envOr("BAS_SERVICE_VERSION", UIM_BAS_VERSION);
  config.defaultRegion = envOr("BAS_DEFAULT_REGION", "eu10");

  auto token = envOr("BAS_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken = true;
    config.authToken = token;
  }

  config.customHeaders["X-Service"] = config.serviceName;
  config.customHeaders["X-Version"] = config.serviceVersion;

  auto service = new BASService(config);
  auto server = new BASServer(service);

  writeln("Starting BAS-like service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
