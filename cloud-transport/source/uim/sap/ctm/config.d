module uim.sap.ctm.config;

import uim.sap.ctm;

mixin(ShowModule!());

@safe:

struct CTMConfig : SAPConfig {
  mixin(SAPConfigTemplate!HTMRepoConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8100));
    basePath(initData.getString("basePath", "/api/cloud-transport"));
    host(initData.getString("host", "0.0.0.0"));
    serviceName(initData.getString("serviceName", "uim-ctm"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  string runtime = "cloud-foundry";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (runtime.length == 0)
      throw new CTMConfigurationException("Runtime cannot be empty");
    if (requireAuthToken && authToken.length == 0)
      throw new CTMConfigurationException("Auth token required when token auth is enabled");
  }
}
