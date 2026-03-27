/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.con;
mixin(ShowModule!());

@safe:
version (unittest) {
} else {
  void main() {
  CONConfig config = new CONConfig();
  config.host = envOr("CON_HOST", "0.0.0.0");
  config.port = readPort(envOr("CON_PORT", "8085"), 8085);
  config.basePath = envOr("CON_BASE_PATH", "/api/con");
  config.serviceName = envOr("CON_SERVICE_NAME", "uim-con");
  config.serviceVersion = envOr("CON_SERVICE_VERSION", UIM_CON_VERSION);
  config.connectorLocationId = envOr("CON_CONNECTOR_LOCATION_ID", defaultLocationId.toString()); // "default-location"

  auto token = envOr("CON_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true);
    config.authToken(token);
  }

  config.customHeader("X-Service", config.serviceName);
  config.customHeader("X-Version", config.serviceVersion);

  auto service = new CONService(config);
  auto server = new CONServer(service);

  writeln("Starting Connectivity service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  
  server.run();
}

}