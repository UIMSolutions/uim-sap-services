/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cmg.config;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:
class CMGConfig : SAPConfig {
  mixin(SAPConfigTemplate!CMGConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8095));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/cmg"));
    serviceName(initData.getString("serviceName", "uim-cmg"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (requireAuthToken && authToken.length == 0)
      throw new CMGConfigurationException("Auth token required when token auth is enabled");
  }
}
