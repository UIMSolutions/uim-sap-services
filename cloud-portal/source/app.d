/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.cps;

mixin(ShowModule!());

@safe:

void main() {
  CPSConfig config;
  config.host = envOr("CPS_HOST", "0.0.0.0");
  config.port = readPort(envOr("CPS_PORT", "8089"), 8089);
  config.basePath = envOr("CPS_BASE_PATH", "/api/cps");
  config.serviceName = envOr("CPS_SERVICE_NAME", "uim-cps");
  config.serviceVersion = envOr("CPS_SERVICE_VERSION", UIM_CPS_VERSION);
  config.defaultTheme = envOr("CPS_DEFAULT_THEME", "sap_fiori_3");

  auto token = envOr("CPS_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true);
    config.authToken(token);
  }

  config.customHeaders["X-Service"] = config.serviceName;
  config.customHeaders["X-Version"] = config.serviceVersion;

  auto service = new CPSService(config);
  auto server = new CPSServer(service);

  writeln("Starting Cloud Portal service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
