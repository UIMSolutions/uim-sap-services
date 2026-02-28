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
  * - `serviceName`: The name of the CIS service (default: "uim-sap-cis")
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
  * CISConfig config;
  * config.host = "0.0.0.0";
  * config.port = 8088;
  * config.basePath = "/api/cis";
  * config.serviceName = "uim-sap-cis";
  * config.serviceVersion = "1.0.0";
  * config.defaultAuthMethod = "form";
  * config.requireAuthToken = true;
  * config.authToken = "my-secret-token";       
  * config.validate();
  * ``` 
  */
struct CISConfig {
  string host = "0.0.0.0";
  ushort port = 8088;
  string basePath = "/api/cis";

  string serviceName = "uim-sap-cis";
  string serviceVersion = "1.0.0";
  string defaultAuthMethod = "form";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  void validate() const {
    if (host.length == 0) {
      throw new CISConfigurationException("Host cannot be empty");
    }
    if (port == 0) {
      throw new CISConfigurationException("Port must be greater than zero");
    }
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new CISConfigurationException("Base path must start with '/'");
    }
    if (serviceName.length == 0) {
      throw new CISConfigurationException("Service name cannot be empty");
    }
    if (defaultAuthMethod.length == 0) {
      throw new CISConfigurationException("Default auth method cannot be empty");
    }
    auto normalized = toLower(defaultAuthMethod);
    if (normalized != "form" && normalized != "spnego" && normalized != "social" && normalized != "2fa") {
      throw new CISConfigurationException("Unsupported default auth method");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new CISConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
///
unittest {
  mixin(ShowTest!("Testing CISConfig validation"));

  CISConfig config;
  config.host = "0.0.0.0";
  config.port = 8088;
  config.basePath = "/api/cis";
  config.serviceName = "uim-sap-cis";
  config.defaultAuthMethod = "form";
  config.requireAuthToken = true;
  config.authToken = "my-secret-token";
  config.validate();

  assert(config.host == "0.0.0.0");
  assert(config.port == 8088);
  assert(config.basePath == "/api/cis");
  assert(config.serviceName == "uim-sap-cis");
  assert(config.defaultAuthMethod == "form");
  assert(config.requireAuthToken == true);
  assert(config.authToken == "my-secret-token");
}
