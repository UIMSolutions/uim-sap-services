/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.slm.config;

import uim.sap.slm;

mixin(ShowModule!());

@safe:

class SLMConfig : SAPConfig {
  mixin(SAPConfigTemplate!HTMRepoConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    basePath(initData.getString("basePath", "/api/solution-lifecycle"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8120));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-slm"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  string runtime = "cloud-foundry";

  override void validate() {
    super.validate();

    if (runtime.length == 0) {
      throw new SLMConfigurationException("Runtime cannot be empty");
    }
  }
}
