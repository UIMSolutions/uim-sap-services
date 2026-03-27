module app;

import uim.sap.mgt;

mixin(ShowModule!());

@safe:
version (unittest) {
} else {
  void main() {
  MGTConfig config = new MGTConfig;
  config.host = envOr("MGT_HOST", "0.0.0.0");
  config.port = readPort(envOr("MGT_PORT", "8088"), 8088);
  config.basePath = envOr("MGT_BASE_PATH", "/api/mgt");
  config.serviceName = envOr("MGT_SERVICE_NAME", "uim-mgt");
  config.serviceVersion = envOr("MGT_SERVICE_VERSION", UIM_MGT_VERSION);

  auto token = envOr("MGT_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true);
    config.authToken(token);
  }

  config.tenant = envOr("MGT_BTP_TENANT", "");
  config.subdomain = envOr("MGT_BTP_SUBDOMAIN", "");
  config.region = envOr("MGT_BTP_REGION", "api.sap.hana.ondemand.com");
  config.username = envOr("MGT_BTP_USERNAME", "");
  config.password = envOr("MGT_BTP_PASSWORD", "");
  config.clientId = envOr("MGT_BTP_CLIENT_ID", "");
  config.clientSecret = envOr("MGT_BTP_CLIENT_SECRET", "");
  config.accessToken = envOr("MGT_BTP_ACCESS_TOKEN", "");
  config.useOAuth2 = readBool(envOr("MGT_BTP_USE_OAUTH2", "false"), false);

  config.customHeader("X-Service", config.serviceName);
  config.customHeader("X-Version", config.serviceVersion);

  auto service = new MGTService(config);
  auto server = new MGTServer(service);

  writeln("Starting MGT service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}

private bool readBool(string value, bool fallback) {
  auto normalized = value.toLower();
  if (normalized == "1" || normalized == "true" || normalized == "yes" || normalized == "on") {
    return true;
  }
  if (normalized == "0" || normalized == "false" || normalized == "no" || normalized == "off") {
    return false;
  }
  return fallback;
}
