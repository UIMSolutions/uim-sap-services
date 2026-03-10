/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.rms;

mixin(ShowModule!());

@safe:
void main() {
  RMSConfig config = new RMSConfig();
  config.host = envOr("RMS_HOST", "0.0.0.0");
  config.port = readPort(envOr("RMS_PORT", "8095"), 8095);
  config.basePath = envOr("RMS_BASE_PATH", "/api/rms");
  config.serviceName = envOr("RMS_SERVICE_NAME", "uim-rms");
  config.serviceVersion = envOr("RMS_SERVICE_VERSION", UIM_RMS_VERSION);
  config.dataDirectory = envOr("RMS_DATA_DIR", "/tmp/uim-rms-data");
  config.defaultTenant = envOr("RMS_DEFAULT_TENANT", "provider");
  config.defaultSpace = envOr("RMS_DEFAULT_SPACE", "dev");
  config.logRetention = readInt(envOr("RMS_LOG_RETENTION", "500"), 500);

  auto token = envOr("RMS_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireManagementAuth = true;
    config.managementAuthToken = token;
  }

  config.customHeaders["X-Service"] = config.serviceName;
  config.customHeaders["X-Version"] = config.serviceVersion;

  auto service = new RMSService(config);
  auto server = new RMSServer(service);

  writeln("Starting Responsibility Management service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}
