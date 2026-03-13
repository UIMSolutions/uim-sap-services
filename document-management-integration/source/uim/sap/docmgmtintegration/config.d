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

  override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
      return false;
    }

    // Network
    basePath(initdata.getString("basePath", "/api/docmgmt-integration"));
    host(initdata.getString("host", "0.0.0.0"));
    port(cast(ushort)initdata.getInteger("port", 8091));

    // Service metadata
    serviceName(initdata.getString("serviceName", "uim-docmgmt-integration"));
    serviceVersion(initdata.getString("serviceVersion", "1.0.0"));

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

  /// Authentication
  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (maxUploadSizeMB <= 0) {
      throw new DocMgmtIntegrationConfigurationException(
        "Max upload size must be greater than zero");
    }
    if (encryptionEnabled && encryptionKey.length == 0) {
      throw new DocMgmtIntegrationConfigurationException(
        "Encryption key is required when encryption is enabled");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new DocMgmtIntegrationConfigurationException(
        "Auth token is required when authentication is enabled");
    }
  }
}
