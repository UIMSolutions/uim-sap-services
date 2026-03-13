module uim.sap.prm.config;

import uim.sap.prm;

mixin(ShowModule!());

@safe:

class PRMConfig : SAPConfig {
  mixin(SAPConfigTemplate!PRMConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8096));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/prm"));
    serviceName(initData.getString("serviceName", "uim-prm"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));
    defaultCapacityHours = initData.getDouble("defaultCapacityHours", 8);

    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  double defaultCapacityHours = 8;

  override void validate() const {
    super.validate();
    if (defaultCapacityHours <= 0) {
      throw new PRMConfigurationException("defaultCapacityHours must be greater than 0");
    }
  }
}
