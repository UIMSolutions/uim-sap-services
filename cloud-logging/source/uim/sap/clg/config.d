/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clg.config;

import uim.sap.clg;

mixin(ShowModule!());

@safe:

class CLGConfig : SAPConfig {
  mixin(SAPConfigTemplate!CLGConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    port(cast(ushort)initData.getInteger("port", 8081));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/sap/cloud/logging/v1"));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-clg"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  size_t maxEntries = 10000;
  size_t defaultQueryLimit = 100;

  override void validate() {
    super.validate();

    if (maxEntries == 0) {
      throw new CLGConfigurationException("maxEntries must be greater than zero");
    }

    if (defaultQueryLimit == 0) {
      throw new CLGConfigurationException("defaultQueryLimit must be greater than zero");
    }
  }
}
