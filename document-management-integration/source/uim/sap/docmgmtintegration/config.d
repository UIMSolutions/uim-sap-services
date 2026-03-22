/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.docmgmtintegration.config;

import uim.sap.docmgmtintegration;

mixin(ShowModule!());

@safe:

/** 
  * Configuration class for the Document Management Integration service.
  * This class extends the base SAPConfig and adds specific settings for document management.
  * It includes properties for upload limits, encryption, versioning, multitenancy, and authentication.
  * The initialize method populates the configuration from a JSON object, and the validate method checks for required fields and logical consistency.
  */
class DocMgmtIntegrationConfig : SAPConfig {
  mixin(SAPConfigTemplate!DocMgmtIntegrationConfig);

  this(Json[string] initData = null) {
    super(initData);
  }

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network
    basePath(initData.getString("basePath", "/api/docmgmt-integration"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8091));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-docmgmt-integration"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  /// Upload limits
  int maxUploadSizeMB = 100;

  /// Default repository identifier
  string defaultRepository = "internal";

  /// Encryption
  bool encryptionEnabled = false;
  string encryptionKey;

  /// Versioning
  bool versioningEnabled = true;

  /// Multitenancy
  bool multitenancyEnabled = true;

  override void validate() {
    super.validate();

    if (maxUploadSizeMB <= 0) {
      throw new DocMgmtIntegrationConfigurationException(
        "Max upload size must be greater than zero");
    }
    if (encryptionEnabled && encryptionKey.length == 0) {
      throw new DocMgmtIntegrationConfigurationException(
        "Encryption key is required when encryption is enabled");
    }
  }
}
