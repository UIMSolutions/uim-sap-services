module uim.sap.docmgmtintegration.config;

import std.string : startsWith, toLower;

import uim.sap.docmgmtintegration.exceptions;

class DocMgmtIntegrationConfig : SAPConfig {
    this() {
        super();
    }

    this(Json[string] initData = null) {
        super(initData);
    }

    /// Network
    string host = "0.0.0.0";
    ushort port = 8091;
    string basePath = "/api/docmgmt-integration";

    /// Service metadata
    string serviceName = "uim-sap-docmgmt-integration";
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

    /// Multitenancy
    bool multitenancyEnabled = true;

    /// Authentication
    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new DocMgmtIntegrationConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new DocMgmtIntegrationConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new DocMgmtIntegrationConfigurationException("Base path must start with '/'");
        }
        if (serviceName.length == 0) {
            throw new DocMgmtIntegrationConfigurationException("Service name cannot be empty");
        }
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
