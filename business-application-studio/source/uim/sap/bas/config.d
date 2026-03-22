module uim.sap.bas.config;

import uim.sap.bas;

mixin(ShowModule!());

@safe:

class BASConfig : SAPConfig {
  mixin(SAPConfigTemplate!BASConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8088));
    basePath(initData.getString("basePath", "/api/business-application-studio"));
    host(initData.getString("host", "0.0.0.0"));
    serviceName(initData.getString("serviceName", "uim-bas"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  string defaultRegion = "eu10";

  string[] regions = ["eu10", "us10", "ap10"];
  string[] hyperscalers = ["aws", "azure", "gcp"];

  override void validate() {
    super.validate();

    if (defaultRegion.length == 0) {
      throw new BASConfigurationException("Default region cannot be empty");
    }
  }
}
