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

    port(cast(ushort)initData.getInteger("port", 8094));
    basePath(initData.getString("basePath", "/api/ff"));
    serviceName(initData.getString("serviceName", "uim-ff"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    host(initData.getString("host", "0.0.0.0"));
    return true;
  }
    bool requireAuthToken = false;
    string authToken;
    string[string] customHeaders;

    override void validate() {
        super.validate();
        
        if (requireAuthToken && authToken.length == 0) {
            throw new FFLConfigurationException("Auth token required but not set");
        }
    }
}
