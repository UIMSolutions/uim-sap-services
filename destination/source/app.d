/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.dst;

mixin(ShowModule!());

@safe:
version (unittest) {
} else {
  void main() {
  DSTConfig config = new DSTConfig();
  config.host = envOr("DST_HOST", "0.0.0.0");
  config.port = readPort(envOr("DST_PORT", "8104"), 8104);
  config.basePath = envOr("DST_BASE_PATH", "/api/destination");
  config.serviceName = envOr("DST_SERVICE_NAME", "uim-dst");
  config.serviceVersion = envOr("DST_SERVICE_VERSION", UIM_DST_VERSION);
  config.runtime = envOr("DST_RUNTIME", "cloud-foundry");

  auto token = envOr("DST_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true);
    config.authToken(token);
  }

  config.customHeader("X-Service", config.serviceName);
  config.customHeader("X-Version", config.serviceVersion);

  auto service = new DSTService(config);
  auto server = new DSTServer(service);

  writeln("Starting Destination service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
