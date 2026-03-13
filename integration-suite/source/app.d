/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
  void main() {
    INTConfig config = new INTConfig;
    config.host = envOr("INT_HOST", "0.0.0.0");
    config.port = readPort(envOr("INT_PORT", "8100"), 8100);
    config.basePath = envOr("INT_BASE_PATH", "/api/is");
    config.serviceName = envOr("INT_SERVICE_NAME", "uim-is");
    config.serviceVersion = envOr("INT_SERVICE_VERSION", UIM_INT_VERSION);

    auto token = envOr("INT_AUTH_TOKEN", "");
    if (token.length > 0) {
      config.requireAuthToken(true);
      config.authToken(token);
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new INTService(config);
    auto server = new INTServer(service);

    writeln("Starting Integration Suite service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
  }
}
