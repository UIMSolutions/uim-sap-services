/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.con.config;

import uim.sap.con;

mixin(ShowModule!());

@safe:

class CONConfig : SAPConfig {
  mixin(SAPConfigTemplate!CONConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    port(cast(ushort)initData.getInteger("port", 8085));
    basePath(initData.getString("basePath", "/api/con"));
    host(initData.getString("host", "0.0.0.0"));
    
    // Service metadata
    serviceName(initData.getString("serviceName", "uim-con"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  string connectorLocationId = "default-location";

  override void validate() {
    super.validate();

    if (connectorLocationId.length == 0) {
      throw new CONConfigurationException("Connector location ID cannot be empty");
    }
  }
}
