module uim.sap.dataretention.config;

import uim.sap.dataretention;

mixin(ShowModule!());

@safe:

class DRMConfig : SAPConfig {
  mixin(SAPConfigTemplate!DRMConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network settings
    basePath(initData.getString("basePath", "/api/data-retention"));
    port(cast(ushort)initData.getInteger("port", 8110));
    host(initData.getString("host", "0.0.0.0"));

    // Service settings
    serviceName(initData.getString("serviceName", "uim-data-retention"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication settings
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }
}
