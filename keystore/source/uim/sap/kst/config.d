module uim.sap.kst.config;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

class KSTConfig : SAPConfig {
  mixin(SAPConfigTemplate!KSTConfig);

  override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
      return false;
    }

    port(cast(ushort)initdata.getInteger("port", 8087));
    host(initdata.getString("host", "0.0.0.0"));
    basePath(initdata.getString("basePath", "/api/kst"));
    serviceName(initdata.getString("serviceName", "uim-kst"));
    serviceVersion(initdata.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBool("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  /// Master key used to encrypt private keys at rest
  string masterKey = "uim-kst-dev-master-key";

  /// Whether client certificate authentication is enabled
  bool enableClientCertAuth = false;

  /// Maximum number of keystores that may be stored (0 = unlimited)
  size_t maxKeystores = 0;

  override void validate() const {
    super.validate();

    if (masterKey.length == 0) {
      throw new KSTConfigurationException("Master key cannot be empty");
    }
  }
}
