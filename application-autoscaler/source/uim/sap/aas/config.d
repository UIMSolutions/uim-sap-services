/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aas.config;

import uim.sap.aas;

@safe:

class AASConfig : SAPConfig {
  mixin(SAPConfigTemplate!AASConfig);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(config)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/autoscaler"));
    serviceName(initData.getString("serviceName", "uim-aas"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));
    port(cast(ushort)initData.getInteger("port", 8086));

    // Load AAS-specific configuration
    if (config.canFind("cfApi")) {
      cfApi = config["cfApi"];
    }
    if (config.canFind("cfOrganization")) {
      cfOrganization = config["cfOrganization"];
    }
    if (config.canFind("cfSpace")) {
      cfSpace = config["cfSpace"];
    }

    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }


  string cfApi;
  string cfOrganization;
  string cfSpace;
}
