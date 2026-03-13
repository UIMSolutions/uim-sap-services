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
    override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
       return false;
    }

    port(cast(ushort)initdata.getInteger("port", 8090));
    host(initdata.getString("host", "0.0.0.0"));
    basePath(initdata.getString("basePath", "/api/mon"));
    serviceName(initdata.getString("serviceName", "uim-mon"));
    serviceVersion(initdata.getString("serviceVersion", "1.0.0"));

 bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

    return true;
  }
}
