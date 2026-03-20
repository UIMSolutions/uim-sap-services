module uim.sap.kym.config;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

class KYMConfig : SAPConfig {
  mixin(SAPConfigTemplate!KYMConfig);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network
    basePath(initData.getString("basePath", "/api/kym"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8088));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-kym"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

  bool requireAuthToken = false;
  string authToken;

    return true;
  }


  /// Maximum namespaces per runtime
  size_t maxNamespaces = 100;

  /// Maximum functions per namespace
  size_t maxFunctionsPerNamespace = 500;

  /// Maximum microservices per namespace
  size_t maxMicroservicesPerNamespace = 200;

  /// Maximum event subscriptions per namespace
  size_t maxSubscriptionsPerNamespace = 1000;

  /// Default function timeout in seconds
  size_t defaultFunctionTimeoutSecs = 30;

  /// Default replica count for microservices
  size_t defaultReplicas = 1;


  override void validate() const {
    super.validate();

    if (requireAuthToken && authToken.length == 0)
      throw new KYMConfigurationException("Auth token required when token auth is enabled");
    if (maxNamespaces == 0)
      throw new KYMConfigurationException("maxNamespaces must be greater than zero");
  }
}
