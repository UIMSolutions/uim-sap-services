module uim.sap.atm.config;

import uim.sap.atm;

mixin(ShowModule!());

@safe:

/**
  * ATMConfig defines the configuration parameters for the SAP Authorization Trust Management (ATM) service.
  * It extends the base SAPConfig with additional properties specific to ATM.
  *
  * Configuration parameters include:
  * - host: The hostname or IP address the service will bind to (default: "0.0.0.0")
  * - port: The port number the service will listen on (default: 8088)
  * - basePath: The base path for the API endpoints (default: "/api/atm")
  * - defaultIdpName: The default Identity Provider (IdP) name (default: "sap-id-service")
  * - defaultIdpIssuer: The default IdP issuer URL (default: "https://accounts.sap.com")
  * - defaultIdpAudience: The default IdP audience (default: "uim-app")
  * - allowUnsignedTokens: Whether to allow unsigned tokens (default: true)
  * - enforceTokenExpiry: Whether to enforce token expiry (default: true)
  * - bootstrapToken: The bootstrap token for initial authentication
  * - customHeaders: Custom headers to include in requests
  *
  * The validate() method checks the configuration for required fields and valid values, throwing an ATMConfigurationException if any issues are found.
  *
  * Example usage:
  * var config = new ATMConfig();
  * config.initialize(jsonData);
  * config.validate();
  *
  * Note: The serviceName and serviceVersion properties are inherited from SAPConfig and can be set via the initialize method.
  */
class ATMConfig : SAPConfig {
  mixin(SAPConfigTemplate!AgentryConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    serviceName(initData.getString("serviceName", "uim-atm"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));
    host(initData.getString("host", "0.0.0.0"));

    return true;
  }

  ushort port = 8088;
  string basePath = "/api/atm";

  string defaultIdpName = "sap-id-service";
  string defaultIdpIssuer = "https://accounts.sap.com";
  string defaultIdpAudience = "uim-app";

  bool allowUnsignedTokens = true;
  bool enforceTokenExpiry = true;
  string bootstrapToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

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
