module uim.sap.mdg.config;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:

class MDGConfig : SAPConfig {

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8087));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/mdg"));
    serviceName(initData.getString("serviceName", "uim-mdg"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  string defaultApprover = "mdg-approver";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (defaultApprover.length == 0) {
      throw new MDGConfigurationException("Default approver cannot be empty");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new MDGConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
