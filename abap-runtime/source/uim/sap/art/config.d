/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.art.config;

import uim.sap.art;

mixin(ShowModule!());

@safe:
class ARTRuntimeConfig : SAPConfig {
  mixin(SAPConfigTemplate!ARTRuntimeConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    port(cast(ushort)initData.getInteger("port", 8080));
    host(initData.getString("host", "127.0.0.1"));
    basePath(initData.getString("basePath", "/sap/abap/runtime"));

    // Authentication configuration
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  string runtimeName = "uim-art";
  string runtimeVersion = "1.0.0";

  Duration requestTimeout = 30.seconds;
}
