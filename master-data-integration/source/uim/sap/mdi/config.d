module uim.sap.mdi.config;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:

class MDIConfig : SAPConfig {
  mixin(SAPConfigTemplate!MDIConfig);

  override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
      return false;
    }

    // Network configuration
    basePath(initdata.getString("basePath", "/api/mdi"));
    host(initdata.getString("host", "0.0.0.0"));
    port(cast(ushort)initdata.getInteger("port", 8092));

    // Service metadata
    serviceName(initdata.getString("serviceName", "uim-mdi"));
    serviceVersion(initdata.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBool("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  string defaultObjectType = "business_partner";

  override void validate() const {
    super.validate();

    if (defaultObjectType.length == 0) {
      throw new MDIConfigurationException("Default object type cannot be empty");
    }
  }
}
