/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mon.config;

import uim.sap.mon;

mixin(ShowModule!());

@safe:

class MONConfig : SAPConfig {
  mixin(SAPConfigTemplate!MONConfig);

    override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
       return false;
    }

    port(cast(ushort)initData.getInteger("port", 8090));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/mon"));
    serviceName(initData.getString("serviceName", "uim-mon"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

 bool requireAuthToken = false;
  string authToken;


    return true;
  }
}
