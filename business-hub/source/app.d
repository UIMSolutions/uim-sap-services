/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.buh;

void main() {
  BUHConfig config = new BUHConfig();
  config.host = envOr("BUH_HOST", "0.0.0.0");
  config.port = readPort(envOr("BUH_PORT", "8083"), 8083);
  config.basePath = envOr("BUH_BASE_PATH", "/api/hub");
  config.serviceName = envOr("BUH_SERVICE_NAME", "uim-buh");
  config.serviceVersion = envOr("BUH_SERVICE_VERSION", UIM_BUH_VERSION);

  auto token = envOr("BUH_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true);
    config.authToken(token);
  }

  config.customHeader("X-Service", config.serviceName);
  config.customHeader("X-Version", config.serviceVersion);

  auto service = new BUHService(config);
  auto server = new BUHServer(service);

  writeln("Starting BUH service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
