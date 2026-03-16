/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
  void main() {
    AGTConfig config = new AGTConfig;
    config.host = envOr("AGENTRY_HOST", "0.0.0.0");
    config.port = readPort(envOr("AGENTRY_PORT", "8089"), 8089);
    config.basePath = envOr("AGENTRY_BASE_PATH", "/api/agentry");
    config.serviceName = envOr("AGENTRY_SERVICE_NAME", "uim-agentry");
    config.serviceVersion = envOr("AGENTRY_SERVICE_VERSION", UIM_AGENTRY_VERSION);
    config.defaultBackendSystem = envOr("AGENTRY_DEFAULT_BACKEND", "s4-primary");

    auto token = envOr("AGENTRY_AUTH_TOKEN", "");
    if (token.length > 0) {
      config.requireAuthToken(true);
      config.authToken(token);
    }

    config.customHeader("X-Service", config.serviceName);
    config.customHeader("X-Version", config.serviceVersion);

    auto service = new AGTService(config);
    auto server = new AGTServer(service);

    writeln("Starting Agentry service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
  }
}
