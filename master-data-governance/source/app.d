/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:version (unittest) {
} else {
  void main() {
  MDGConfig config = new MDGConfig();
  config.host = envOr("MDG_HOST", "0.0.0.0");
  config.port = readPort(envOr("MDG_PORT", "8087"), 8087);
  config.basePath = envOr("MDG_BASE_PATH", "/api/mdg");
  config.serviceName = envOr("MDG_SERVICE_NAME", "uim-mdg");
  config.serviceVersion = envOr("MDG_SERVICE_VERSION", UIM_MDG_VERSION);
  config.defaultApprover = envOr("MDG_DEFAULT_APPROVER", "mdg-approver");

  auto token = envOr("MDG_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true);
    config.authToken(token);
  }

  config.customHeader("X-Service", config.serviceName);
  config.customHeader("X-Version", config.serviceVersion);

  auto service = new MDGService(config);
  auto server = new MDGServer(service);

  writeln("Starting MDG service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
