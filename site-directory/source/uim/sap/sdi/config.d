/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.sdi.config;

import uim.sap.sdi;

mixin(ShowModule!());

@safe:

class SDIConfig : SAPConfig {
  mixin(SAPConfigTemplate!SDIConfig);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
       return false;
    }

    port(cast(ushort)initData.getInteger("port", 8096));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/sitedirectory"));
    serviceName(initData.getString("serviceName", "uim-sdi"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken()) {
      authToken(initData.getString("authToken", ""));
    }   

    return true;
  }


  string[string] customHeaders;
}
