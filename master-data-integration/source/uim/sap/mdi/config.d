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

    port(cast(ushort)initdata.getInteger("port", 8092));
    host(initdata.getString("host", "0.0.0.0"));
    basePath(initdata.getString("basePath", "/api/mdi"));
    serviceName(initdata.getString("serviceName", "uim-mdi"));
    serviceVersion(initdata.getString("serviceVersion", "1.0.0"));

    return true;
  }

  string defaultObjectType = "business_partner";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (defaultObjectType.length == 0)
      throw new MDIConfigurationException("Default object type cannot be empty");
    if (requireAuthToken && authToken.length == 0)
      throw new MDIConfigurationException("Auth token required when token auth is enabled");
  }
}
