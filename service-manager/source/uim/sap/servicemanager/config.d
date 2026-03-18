module uim.sap.servicemanager.config;

import uim.sap.servicemanager;

mixin(ShowModule!());

@safe:

class SVMConfig : SAPConfig {
  mixin(SAPConfigTemplate!SVMConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8111));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/service-manager"));
    serviceName(initData.getString("serviceName", "uim-service-manager"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }
}
