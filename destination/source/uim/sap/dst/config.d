module uim.sap.dst.config;

import uim.sap.dst;

mixin(ShowModule!());

@safe:

class DSTConfig : SAPConfig {
  mixin(SAPConfigTemplate!DSTConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8104));
    basePath(initData.getString("basePath", "/api/destination"));
    serviceName(initData.getString("serviceName", "uim-dst"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));
    host(initData.getString("host", "0.0.0.0"));

    return true;
  }

  string runtime = "cloud-foundry";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (runtime.length == 0)
      throw new DSTConfigurationException("Runtime cannot be empty");
    if (requireAuthToken && authToken.length == 0)
      throw new DSTConfigurationException("Auth token required when token auth is enabled");
  }
}
