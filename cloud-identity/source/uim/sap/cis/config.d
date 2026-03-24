module uim.sap.cis.config;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

/** 
  * Configuration for the UIM Cloud Identity Services (CIS) module.
  * This struct holds all the necessary settings to initialize and run the CIS service.
  *
  * Fields:
  * - `host`: The IP address or hostname to bind the server to (default: "0.0.0.0")
  * - `port`: The port number to bind the server to (default: 8088)
  * - `basePath`: The base path for the CIS API (default: "/api/cis")
  * - `serviceName`: The name of the CIS service (default: "uim-cis")
  * - `serviceVersion`: The version of the CIS service (default: "1.0.0")
  * - `defaultAuthMethod`: The default authentication method (default: "form")
  * - `requireAuthToken`: Whether an auth token is required (default: false)
  * - `authToken`: The auth token to use if required
  * - `customHeaders`: Custom headers to include in requests
  *
  * Methods:
  * - `validate()`: Validates the configuration and throws an exception if invalid  
  * Example usage:
  * ```
  * CISConfig config = new CISConfig();
  * config.host = "0.0.0.0";
  * config.port = 8088;
  * config.basePath = "/api/cis";
  * config.serviceName = "uim-cis";
  * config.serviceVersion = "1.0.0";
  * config.defaultAuthMethod = "form";
  * config.requireAuthToken(true);
  * config.authToken = "my-secret-token";       
  * config.validate();
  * ``` 
  */
class CISConfig : SAPConfig {
  mixin(SAPConfigTemplate!CISConfig);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(config)) {
      return false;
    }

    // Network settings
    basePath(initData.getString("basePath", "/api/cis"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8088));

    // Service settings 
    serviceName(initData.getString("serviceName", "uim-cis"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication settings
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  string defaultAuthMethod = "form";

  override void validate() {
    super.validate();

    if (defaultAuthMethod.length == 0) {
      throw new CISConfigurationException("Default auth method cannot be empty");
    }
    auto normalized = toLower(defaultAuthMethod);
    if (normalized != "form" && normalized != "spnego" && normalized != "social" && normalized != "2fa") {
      throw new CISConfigurationException("Unsupported default auth method");
    }
  }
}
///
unittest {
  mixin(ShowTest!("Testing CISConfig validation"));

  CISConfig config = new CISConfig;
  config.host = "0.0.0.0";
  config.port = 8088;
  config.basePath = "/api/cis";
  config.serviceName = "uim-cis";
  config.defaultAuthMethod = "form";
  config.requireAuthToken(true);
  config.authToken = "my-secret-token";
  config.validate();

  assert(config.host == "0.0.0.0");
  assert(config.port == 8088);
  assert(config.basePath == "/api/cis");
  assert(config.serviceName == "uim-cis");
  assert(config.defaultAuthMethod == "form");
  assert(config.requireAuthToken == true);
  assert(config.authToken == "my-secret-token");
}
