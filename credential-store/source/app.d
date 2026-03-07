module app;

import uim.sap.cre;

void main() {
  CREConfig config = new CREConfig();
  config.host = envOr("CRE_HOST", "0.0.0.0");
  config.port = readPort(envOr("CRE_PORT", "8086"), 8086);
  config.basePath = envOr("CRE_BASE_PATH", "/api/cre");
  config.serviceName = envOr("CRE_SERVICE_NAME", "uim-sap-cre");
  config.serviceVersion = envOr("CRE_SERVICE_VERSION", UIM_CRE_VERSION);
  config.masterKey = envOr("CRE_MASTER_KEY", "uim-sap-cre-dev-master-key");

  auto token = envOr("CRE_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken = true;
    config.authToken = token;
  }

  config.customHeaders["X-Service"] = config.serviceName;
  config.customHeaders["X-Version"] = config.serviceVersion;

  auto service = new CREService(config);
  auto server = new CREServer(service);

  writeln("Starting CRE service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
