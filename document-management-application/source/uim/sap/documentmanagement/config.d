/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.documentmanagement.config;

import std.string : startsWith, toLower;

import uim.sap.documentmanagement.exceptions;

class DMAConfig : SAPConfig {
  mixin(SAPConfigTemplate!HTMRepoConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    return true;
  }
  /// Network
  ushort port = 8090;
  string basePath = "/api/docmgmt";

  /// Service metadata
  string serviceName = "uim-document-management";
  string serviceVersion = "1.0.0";

  /// Upload limits
  int maxUploadSizeMB = 100;

  /// Default repository identifier
  string defaultRepository = "internal";

  /// Encryption
  bool encryptionEnabled = false;
  string encryptionKey;

  /// Versioning
  bool versioningEnabled = true;

  /// Authentication
  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (host.length == 0) {
      throw new DMAConfigurationException("Host cannot be empty");
    }
    if (port == 0) {
      throw new DMAConfigurationException("Port must be greater than zero");
    }
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new DMAConfigurationException("Base path must start with '/'");
    }
    if (serviceName.length == 0) {
      throw new DMAConfigurationException("Service name cannot be empty");
    }
    if (maxUploadSizeMB <= 0) {
      throw new DMAConfigurationException("Max upload size must be greater than zero");
    }
    if (encryptionEnabled && encryptionKey.length == 0) {
      throw new DMAConfigurationException(
        "Encryption key is required when encryption is enabled");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new DMAConfigurationException(
        "Auth token is required when authentication is enabled");
    }
  }
}
