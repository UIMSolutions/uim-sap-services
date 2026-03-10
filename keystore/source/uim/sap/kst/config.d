module uim.sap.kst.config;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

struct KSTConfig : SAPConfig {
  string host = "0.0.0.0";
  ushort port = 8087;
  string basePath = "/api/kst";

  string serviceName = "uim-kst";
  string serviceVersion = "1.0.0";

  bool requireAuthToken = false;
  string authToken;

  /// Master key used to encrypt private keys at rest
  string masterKey = "uim-kst-dev-master-key";

  /// Whether client certificate authentication is enabled
  bool enableClientCertAuth = false;

  /// Maximum number of keystores that may be stored (0 = unlimited)
  size_t maxKeystores = 0;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (host.length == 0) {
      throw new KSTConfigurationException("Host cannot be empty");
    }
    if (port == 0) {
      throw new KSTConfigurationException("Port must be greater than zero");
    }
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new KSTConfigurationException("Base path must start with '/'");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new KSTConfigurationException("Auth token required when token auth is enabled");
    }
    if (masterKey.length == 0) {
      throw new KSTConfigurationException("Master key cannot be empty");
    }
  }
}
