/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.clf;
version (unittest) {
} else {
  void main() {
    CLFConfig config = new CLFConfig;
    config.host = envOr("CLF_HOST", "0.0.0.0");
    config.port = readPort(envOr("CLF_PORT", "8082"), 8082);
    config.basePath = envOr("CLF_BASE_PATH", "/api/cf");
    config.serviceName = envOr("CLF_SERVICE_NAME", "uim-clf");
    config.serviceVersion = envOr("CLF_SERVICE_VERSION", UIM_CLF_VERSION);

    auto token = envOr("CLF_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken(true);
        config.authToken(token);
    }

    config.customHeader("X-Service", config.serviceName);
    config.customHeader("X-Version", config.serviceVersion);

    auto service = new CLFService(config);
    auto server = new CLFServer(service);

    writeln("Starting CLF service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
}


