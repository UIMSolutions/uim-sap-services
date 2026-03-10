/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;
import std.string : toLower;

import uim.sap.docmgmtintegration;

version (unittest) {
} else {
  void main() {
    DocMgmtIntegrationConfig config;
    config.host = envOr("DMSI_HOST", "0.0.0.0");
    config.port = readPort(envOr("DMSI_PORT", "8091"), 8091);
    config.basePath = envOr("DMSI_BASE_PATH", "/api/docmgmt-integration");
    config.serviceName = envOr("DMSI_SERVICE_NAME", "uim-docmgmt-integration");
    config.serviceVersion = envOr("DMSI_SERVICE_VERSION", UIM_DOCMGMT_INTEGRATION_VERSION);
    config.maxUploadSizeMB = readInt(envOr("DMSI_MAX_UPLOAD_SIZE_MB", "100"), 100);
    config.defaultRepository = envOr("DMSI_DEFAULT_REPOSITORY", "internal");
    config.versioningEnabled = readBool(envOr("DMSI_VERSIONING_ENABLED", "true"), true);
    config.encryptionEnabled = readBool(envOr("DMSI_ENCRYPTION_ENABLED", "false"), false);
    config.multitenancyEnabled = readBool(envOr("DMSI_MULTITENANCY_ENABLED", "true"), true);

    auto encKey = envOr("DMSI_ENCRYPTION_KEY", "");
    if (encKey.length > 0)
      config.encryptionKey = encKey;

    auto authToken = envOr("DMSI_AUTH_TOKEN", "");
    if (authToken.length > 0) {
      config.requireAuthToken = true;
      config.authToken = authToken;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;
    config.customHeaders["X-Multitenancy"] = config.multitenancyEnabled ? "enabled" : "disabled";

    auto service = new DocMgmtIntegrationService(config);
    auto server = new DocMgmtIntegrationServer(service);

    writeln("Starting Document Management Integration Service on ",
      config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    writeln("Default repository: ", config.defaultRepository);
    writeln("Multitenancy: ", config.multitenancyEnabled ? "enabled" : "disabled");
    writeln("Versioning: ", config.versioningEnabled ? "enabled" : "disabled");
    writeln("Encryption: ", config.encryptionEnabled ? "enabled" : "disabled");
    server.run();
  }
}

private bool readBool(string value, bool fallback) {
  auto lower = toLower(value);
  if (lower == "true" || lower == "1" || lower == "yes")
    return true;
  if (lower == "false" || lower == "0" || lower == "no")
    return false;
  return fallback;
}

