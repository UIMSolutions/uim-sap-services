module uim.sap.mdg.config;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:

struct MDGConfig : SAPConfig {
  string host = "0.0.0.0";
  ushort port = 8087;
  string basePath = "/api/mdg";

  string serviceName = "uim-mdg";
  string serviceVersion = "1.0.0";
  string defaultApprover = "mdg-approver";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  void validate() const {
    super.validate();

    if (host.length == 0) {
      throw new MDGConfigurationException("Host cannot be empty");
    }
    if (port == 0) {
      throw new MDGConfigurationException("Port must be greater than zero");
    }
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new MDGConfigurationException("Base path must start with '/'");
    }
    if (serviceName.length == 0) {
      throw new MDGConfigurationException("Service name cannot be empty");
    }
    if (defaultApprover.length == 0) {
      throw new MDGConfigurationException("Default approver cannot be empty");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new MDGConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
