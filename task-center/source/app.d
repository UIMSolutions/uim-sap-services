/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.tkc;

mixin(ShowModule!());

@safe:
void main() {
  TKCConfig config = new TKCConfig();
  config.host = envOr("TKC_HOST", "0.0.0.0");
  config.port = readPort(envOr("TKC_PORT", "8096"), 8096);
  config.basePath = envOr("TKC_BASE_PATH", "/api/task-center");
  config.serviceName = envOr("TKC_SERVICE_NAME", "uim-task-center");
  config.serviceVersion = envOr("TKC_SERVICE_VERSION", UIM_TKC_VERSION);
  config.dataDirectory = envOr("TKC_DATA_DIR", "/tmp/uim-task-center-data");
  config.cacheFileName = envOr("TKC_CACHE_FILE", "task-cache.json");

  auto token = envOr("TKC_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken = true;
    config.authToken = token;
  }

  config.customHeaders["X-Service"] = config.serviceName;
  config.customHeaders["X-Version"] = config.serviceVersion;

  auto service = new TKCService(config);
  auto server = new TKCServer(service);

  writeln("Starting Task Center service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  writeln("Data directory: ", config.dataDirectory);
  server.run();
  runApplication();
}

