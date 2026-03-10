/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clg.config;

import uim.sap.clg;

mixin(ShowModule!());

@safe:

struct CLGConfig : SAPConfig {
  mixin(SAPConfigTemplate!CLGConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/sap/cloud/logging/v1"));
    serviceName(initData.getString("serviceName", "uim-clg"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  ushort port = 8081;

  size_t maxEntries = 10000;
  size_t defaultQueryLimit = 100;

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (host.length == 0) {
      throw new CLGConfigurationException("Host cannot be empty");
    }

    if (port == 0) {
      throw new CLGConfigurationException("Port must be greater than zero");
    }

    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new CLGConfigurationException("Base path must start with '/'");
    }

    if (maxEntries == 0) {
      throw new CLGConfigurationException("maxEntries must be greater than zero");
    }

    if (defaultQueryLimit == 0) {
      throw new CLGConfigurationException("defaultQueryLimit must be greater than zero");
    }

    if (requireAuthToken && authToken.length == 0) {
      throw new CLGConfigurationException("authToken is required when requireAuthToken is enabled");
    }
  }
}
