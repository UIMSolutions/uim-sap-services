/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:
void main() {
  MDIConfig config = new MDIConfig();
  config.host = envOr("MDI_HOST", "0.0.0.0");
  config.port = readPort(envOr("MDI_PORT", "8092"), 8092);
  config.basePath = envOr("MDI_BASE_PATH", "/api/mdi");
  config.serviceName = envOr("MDI_SERVICE_NAME", "uim-mdi");
  config.serviceVersion = envOr("MDI_SERVICE_VERSION", UIM_MDI_VERSION);
  config.defaultObjectType = envOr("MDI_DEFAULT_OBJECT_TYPE", "business_partner");

  auto token = envOr("MDI_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken = true;
    config.authToken = token;
  }

  config.customHeaders["X-Service"] = config.serviceName;
  config.customHeaders["X-Version"] = config.serviceVersion;

  auto service = new MDIService(config);
  auto server = new MDIServer(service);

  writeln("Starting MDI service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
