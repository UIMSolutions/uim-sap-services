module app;

import uim.sap.dpi;

void main() {
  DPIConfig config = new DPIConfig();
  config.host = envOr("DPI_HOST", "0.0.0.0");
  config.port = readPort(envOr("DPI_PORT", "8093"), 8093);
  config.basePath = envOr("DPI_BASE_PATH", "/api/dpi");
  config.serviceName = envOr("DPI_SERVICE_NAME", "uim-sap-dpi");
  config.serviceVersion = envOr("DPI_SERVICE_VERSION", UIM_DPI_VERSION);
  config.defaultRetentionDays = readInt(envOr("DPI_DEFAULT_RETENTION_DAYS", "365"), 365);

  auto token = envOr("DPI_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken = true;
    config.authToken = token;
  }

  config.customHeaders["X-Service"] = config.serviceName;
  config.customHeaders["X-Version"] = config.serviceVersion;

  auto service = new DPIService(config);
  auto server = new DPIServer(service);

  writeln("Starting DPI service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}

