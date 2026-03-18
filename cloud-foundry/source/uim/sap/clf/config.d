/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.config;

import uim.sap.clf;

mixin(ShowModule!());

@safe:

class CLFConfig : SAPConfig {
  mixin(SAPConfigTemplate!AgentryConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    basePath(initData.getString("basePath", "/api/cf"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8082));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-clf"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }
    
    return true;
  }
}
///
unittest {
  CLFConfig config = new CLFConfig();
  assert(config.basePath == "/api/cf");
  assert(config.host == "0.0.0.0");
  assert(config.port == 8082);
  assert(config.serviceName == "uim-clf");
  assert(config.serviceVersion == "1.0.0");
  assert(config.requireAuthToken == false);
}