/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.cid;

void main() {
  CIDConfig config = new CIDConfig();
  config.host = envOr("CID_HOST", "0.0.0.0");
  config.port = readPort(envOr("CID_PORT", "8102"), 8102);
  config.basePath = envOr("CID_BASE_PATH", "/api/cicd");
  config.serviceName = envOr("CID_SERVICE_NAME", "uim-cid");
  config.serviceVersion = envOr("CID_SERVICE_VERSION", UIM_CID_VERSION);
  config.runtime = envOr("CID_RUNTIME", "cloud-foundry");

  auto token = envOr("CID_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true);
    config.authToken(token);
  }

  config.customHeaders("X-Service", config.serviceName);
  config.customHeaders("X-Version", config.serviceVersion);

  auto service = new CIDService(config);
  auto server = new CIDServer(service);

  writeln("Starting Continuous Integration & Delivery service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
