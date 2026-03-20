module uim.sap.cre.config;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

class CREConfig : SAPConfig {
  mixin(SAPConfigTemplate!(CREConfig));

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8086));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/cre"));
    serviceName(initData.getString("serviceName", "uim-cre"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    requireAuthToken(initData.getBool("requireAuthToken", false));
    if (requireAuthToken) {
      authToken = initData.getString("authToken", "");
    }

    return true;
  }

  string masterKey = "uim-cre-dev-master-key";

  override void validate() const {
    super.validate();

    if (masterKey.length == 0) {
      throw new CREConfigurationException("Master key cannot be empty");
    }
  }
}
