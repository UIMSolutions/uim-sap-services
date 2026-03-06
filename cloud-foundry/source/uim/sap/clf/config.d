/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.config;

import uim.sap.clf;

mixin(ShowModule!());

@safe:

class CLFConfig : SAPHostConfig {
  mixin(SAPConfigTemplate!AgentryConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
  }
  
    ushort port = 8082;
    string basePath = "/api/cf";

    string serviceName = "uim-sap-clf";
    string serviceVersion = "1.0.0";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new CLFConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new CLFConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new CLFConfigurationException("Base path must start with '/'");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new CLFConfigurationException("Auth token required when token auth is enabled");
        }
    }
}
