/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.smg.config;

import uim.sap.smg;

mixin(ShowModule!());

@safe:

class SMGConfig : SAPConfig {
  mixin(SAPConfigTemplate!SMGConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    /// Netwerk
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8094));
    basePath(initData.getString("basePath", "/api/sitemanager"));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-smg"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication
    requireAuthToken(initData.getBool("requireAuthToken", false));
    if (requireAuthToken()) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }
}
