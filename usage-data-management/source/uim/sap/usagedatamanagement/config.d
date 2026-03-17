module uim.sap.usagedatamanagement.config;

import uim.sap.usagedatamanagement;

mixin(ShowModule!());

@safe:

class UDMConfig : SAPConfig {
  mixin(SAPConfigTemplate!UDMConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8109));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/usage-data-management"));
    serviceName(initData.getString("serviceName", "uim-usage-data-management"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }
}
