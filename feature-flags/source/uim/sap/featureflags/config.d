/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.featureflags.config;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

class FFLConfig : SAPConfig {
  mixin(SAPConfigTemplate!HTMRepoConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    return true;
  }
    ushort port = 8094;
    string basePath = "/api/ff";
    string serviceName = "uim-ff";
    string serviceVersion = "1.0.0";
    bool requireAuthToken = false;
    string authToken;
    string[string] customHeaders;

    void validate() {
        if (port == 0) {
            throw new FFLConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0) {
            throw new FFLConfigurationException("Base path cannot be empty");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new FFLConfigurationException("Auth token required but not set");
        }
    }
}
