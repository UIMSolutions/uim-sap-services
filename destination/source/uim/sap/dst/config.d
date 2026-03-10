module uim.sap.dst.config;

import uim.sap.dst;

mixin(ShowModule!());

@safe:

struct DSTConfig : SAPConfig {
  mixin(SAPConfigTemplate!HTMRepoConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    return true;
  }

    ushort port = 8104;
    string basePath = "/api/destination";

    string serviceName    = "uim-sap-dst";
    string serviceVersion = "1.0.0";
    string runtime        = "cloud-foundry";

    bool   requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0)
            throw new DSTConfigurationException("Host cannot be empty");
        if (port == 0)
            throw new DSTConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/"))
            throw new DSTConfigurationException("Base path must start with '/'");
        if (serviceName.length == 0)
            throw new DSTConfigurationException("Service name cannot be empty");
        if (runtime.length == 0)
            throw new DSTConfigurationException("Runtime cannot be empty");
        if (requireAuthToken && authToken.length == 0)
            throw new DSTConfigurationException("Auth token required when token auth is enabled");
    }
}
