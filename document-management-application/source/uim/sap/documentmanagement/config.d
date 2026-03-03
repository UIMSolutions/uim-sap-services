module uim.sap.documentmanagement.config;

import std.string : startsWith, toLower;

import uim.sap.documentmanagement.exceptions;

class DocumentManagementConfig : SAPConfig {
    this() {
        super();
    }

    this(Json[string] initData = null) {
        super(initData);
    }

    /// Network
    string host = "0.0.0.0";
    ushort port = 8090;
    string basePath = "/api/docmgmt";

    /// Service metadata
    string serviceName = "uim-sap-document-management";
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

    void validate() const {
        if (host.length == 0) {
            throw new DocumentManagementConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new DocumentManagementConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new DocumentManagementConfigurationException("Base path must start with '/'");
        }
        if (serviceName.length == 0) {
            throw new DocumentManagementConfigurationException("Service name cannot be empty");
        }
        if (maxUploadSizeMB <= 0) {
            throw new DocumentManagementConfigurationException("Max upload size must be greater than zero");
        }
        if (encryptionEnabled && encryptionKey.length == 0) {
            throw new DocumentManagementConfigurationException(
                "Encryption key is required when encryption is enabled");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new DocumentManagementConfigurationException(
                "Auth token is required when authentication is enabled");
        }
    }
}
