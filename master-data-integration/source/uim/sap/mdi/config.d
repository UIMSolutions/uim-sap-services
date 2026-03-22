module uim.sap.mdi.config;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:

class MDIConfig : SAPConfig {
  mixin(SAPConfigTemplate!MDIConfig);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    basePath(initData.getString("basePath", "/api/mdi"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8092));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-mdi"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  string defaultObjectType = "business_partner";

  override void validate() {
    super.validate();

    if (defaultObjectType.length == 0) {
      throw new MDIConfigurationException("Default object type cannot be empty");
    }
  }
}
