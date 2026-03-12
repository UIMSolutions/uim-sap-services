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

  override bool initialize(Json[string] initdata) {
    if (!super.initialize(config)) {
      return false;
    }

    host(initdata.getString("host", "0.0.0.0"));
    basePath(initdata.getString("basePath", "/api/autoscaler"));
    serviceName(initdata.getString("serviceName", "uim-aas"));
    serviceVersion(initdata.getString("serviceVersion", "1.0.0"));

    // Load AAS-specific configuration
    if (config.canFind("port")) {
      port = cast(ushort)config["port"].to!int;
    }
    if (config.canFind("cfApi")) {
      cfApi = config["cfApi"];
    }
    if (config.canFind("cfOrganization")) {
      cfOrganization = config["cfOrganization"];
    }
    if (config.canFind("cfSpace")) {
      cfSpace = config["cfSpace"];
    }
    if (config.canFind("requireAuthToken")) {
      requireAuthToken = config["requireAuthToken"].to!bool;
    }
    if (config.canFind("authToken")) {
      authToken = config["authToken"];
    }

    return true;
  }

  ushort port = 8086;

  string cfApi;
  string cfOrganization;
  string cfSpace;

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (requireAuthToken && authToken.length == 0) {
      throw new AASConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
