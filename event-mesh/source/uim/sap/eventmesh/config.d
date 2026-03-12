/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.eventmesh.config;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EVMConfig : SAPConfig {
  mixin(SAPConfigTemplate!EVMConfig);

  override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
      return false;
    }

    basePath(initdata.getString("basePath", "/api/em"));
    host(initdata.getString("host", "0.0.0.0"));
    port(cast(ushort)initdata.getInteger("port", 8092));
    serviceName(initdata.getString("serviceName", "uim-em"));
    serviceVersion(initdata.getString("serviceVersion", "1.0.0"));

    return true;
  }

  bool requireAuthToken = false;
  string authToken;
  string[string] customHeaders;

  override void validate() {
    super.validate();

    if (requireAuthToken && authToken.length == 0) {
      throw new EVMConfigurationException("Auth token required but not set");
    }
  }
}
