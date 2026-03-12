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

    host(initData.getString("host", "127.0.0.1"));
    basePath(initData.getString("basePath", "/sap/abap/runtime"));

    return true;
  }

  ushort port = 8080;

  string runtimeName = "uim-art";
  string runtimeVersion = "1.0.0";
  string authToken;

  Duration requestTimeout = 30.seconds;
  bool requireAuthToken = false;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (requireAuthToken && authToken.length == 0) {
      throw new ARTRuntimeConfigurationException(
        "Auth token is required when requireAuthToken is enabled"
      );
    }
  }
}
