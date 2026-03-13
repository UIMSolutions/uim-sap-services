/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.documentmanagement;

version (unittest) {
} else {
  void main() {
    DocumentManagementConfig config = new DocumentManagementConfig();
    config.host = envOr("DMS_HOST", "0.0.0.0");
    config.port = readPort(envOr("DMS_PORT", "8090"), 8090);
    config.basePath = envOr("DMS_BASE_PATH", "/api/docmgmt");
    config.serviceName = envOr("DMS_SERVICE_NAME", "uim-document-management");
    config.serviceVersion = envOr("DMS_SERVICE_VERSION", UIM_DMAUMENT_MANAGEMENT_VERSION);
    config.maxUploadSizeMB = readInt(envOr("DMS_MAX_UPLOAD_SIZE_MB", "100"), 100);
    config.defaultRepository = envOr("DMS_DEFAULT_REPOSITORY", "internal");
    config.versioningEnabled = readBool(envOr("DMS_VERSIONING_ENABLED", "true"), true);
    config.encryptionEnabled = readBool(envOr("DMS_ENCRYPTION_ENABLED", "false"), false);

    auto encKey = envOr("DMS_ENCRYPTION_KEY", "");
    if (encKey.length > 0)
      config.encryptionKey = encKey;

    auto authToken = envOr("DMS_AUTH_TOKEN", "");
    if (authToken.length > 0) {
      config.requireAuthToken(true);
      config.authToken = authToken;
    }

    config.customHeader("X-Service", config.serviceName);
    config.customHeader("X-Version", config.serviceVersion);

    auto service = new DocumentManagementService(config);
    auto server = new DocumentManagementServer(service);

    writeln("Starting Document Management Service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    writeln("Default repository: ", config.defaultRepository);
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

private double readDouble(string value, double fallback) {
  try {
    return to!double(value);
  } catch (Exception) {
    return fallback;
  }
}
