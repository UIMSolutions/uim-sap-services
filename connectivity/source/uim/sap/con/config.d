module uim.sap.con.config;

import std.string : startsWith;

import uim.sap.con.exceptions;

struct CONConfig : SAPConfig {
  mixin(SAPConfigTemplate!CONConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    return true;
  }

    ushort port = 8085;
    string basePath = "/api/con";

    string serviceName = "uim-sap-con";
    string serviceVersion = "1.0.0";
    string connectorLocationId = "default-location";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new CONConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new CONConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new CONConfigurationException("Base path must start with '/'");
        }
        if (serviceName.length == 0) {
            throw new CONConfigurationException("Service name cannot be empty");
        }
        if (connectorLocationId.length == 0) {
            throw new CONConfigurationException("Connector location ID cannot be empty");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new CONConfigurationException("Auth token required when token auth is enabled");
        }
    }
}
