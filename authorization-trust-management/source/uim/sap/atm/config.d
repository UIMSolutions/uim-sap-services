module uim.sap.atm.config;

import uim.sap.atm;

mixin(ShowModule!());

@safe:

class ATMConfig : SAPConfig {
  mixin(SAPConfigTemplate!AgentryConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
  }
    ushort port = 8088;
    string basePath = "/api/atm";

    string serviceName = "uim-sap-atm";
    string serviceVersion = "1.0.0";

    string defaultIdpName = "sap-id-service";
    string defaultIdpIssuer = "https://accounts.sap.com";
    string defaultIdpAudience = "uim-sap-app";

    bool allowUnsignedTokens = true;
    bool enforceTokenExpiry = true;
    string bootstrapToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new ATMConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new ATMConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new ATMConfigurationException("Base path must start with '/'");
        }
        if (serviceName.length == 0) {
            throw new ATMConfigurationException("Service name cannot be empty");
        }
        if (defaultIdpName.length == 0) {
            throw new ATMConfigurationException("Default IdP name cannot be empty");
        }
        if (defaultIdpIssuer.length == 0) {
            throw new ATMConfigurationException("Default IdP issuer cannot be empty");
        }
    }
}
