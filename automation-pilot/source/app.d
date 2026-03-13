/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.atp;

mixin(ShowModule!());

@safe:
void main() {
  ATPConfig config = new ATPConfig;
  config.host = envOr("ATP_HOST", "0.0.0.0");
  config.port = readPort(envOr("ATP_PORT", "8097"), 8097);
  config.basePath = envOr("ATP_BASE_PATH", "/api/automation-pilot");
  config.serviceName = envOr("ATP_SERVICE_NAME", "uim-atp");
  config.serviceVersion = envOr("ATP_SERVICE_VERSION", UIM_ATP_VERSION);
  config.aiProvider = envOr("ATP_AI_PROVIDER", "mock-genai");

  auto token = envOr("ATP_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true);
    config.authToken(token);
  }

  config.customHeaders("X-Service", config.serviceName);
  config.customHeaders("X-Version", config.serviceVersion);

  auto service = new ATPService(config);
  auto server = new ATPServer(service);

  writeln("Starting Automation Pilot service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
