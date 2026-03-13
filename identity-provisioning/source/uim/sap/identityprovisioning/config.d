/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.identityprovisioning.config;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

class IPVConfig : SAPConfig {
  override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
      return false;
    }

    // Network configuration
    basePath(initdata.getString("basePath", "/api/ip"));
    host(initdata.getString("host", "0.0.0.0"));
    port(initdata.get("port", 8095));

    // Service metadata
    serviceName(initdata.getString("serviceName", "uim-ip"));
    serviceVersion(initdata.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBool("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }
}
