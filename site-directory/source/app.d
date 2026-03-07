/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.sdi;

void main() {
  SDIConfig config;
  config.host = envOr("SDI_HOST", "0.0.0.0");
  config.port = readPort(envOr("SDI_PORT", "8096"), 8096);
  config.basePath = envOr("SDI_BASE_PATH", "/api/sitedirectory");
  config.serviceName = envOr("SDI_SERVICE_NAME", "uim-sap-sdi");
  config.serviceVersion = envOr("SDI_SERVICE_VERSION", UIM_SDI_VERSION);

  auto token = envOr("SDI_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken = true;
    config.authToken = token;
  }

  config.customHeaders["X-Service"] = config.serviceName;
  config.customHeaders["X-Version"] = config.serviceVersion;

  auto service = new SDIService(config);
  auto server = new SDIServer(service);

  writeln("Starting Site Directory service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}


