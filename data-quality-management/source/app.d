module app;

import uim.sap.dqm;

void main() {
  DQMConfig config = new DQMConfig();
  config.host = envOr("DQM_HOST", "0.0.0.0");
  config.port = readPort(envOr("DQM_PORT", "8091"), 8091);
  config.basePath = envOr("DQM_BASE_PATH", "/api/dqm");
  config.serviceName = envOr("DQM_SERVICE_NAME", "uim-dqm");
  config.serviceVersion = envOr("DQM_SERVICE_VERSION", UIM_DQM_VERSION);
  config.defaultCountry = envOr("DQM_DEFAULT_COUNTRY", "DE");

  auto token = envOr("DQM_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken = true;
    config.authToken = token;
  }

  config.customHeaders["X-Service"] = config.serviceName;
  config.customHeaders["X-Version"] = config.serviceVersion;

  auto service = new DQMService(config);
  auto server = new DQMServer(service);

  writeln("Starting DQM service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
