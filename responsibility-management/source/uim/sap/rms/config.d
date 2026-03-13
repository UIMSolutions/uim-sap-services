/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.rms.config;

import uim.sap.rms;

mixin(ShowModule!());

@safe:

class RMSConfig : SAPConfig {
  mixin(SAPConfigTemplate!RMSConfig);

  override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
      return false;
    }

    // Network configuration
    basePath(initdata.getString("basePath", "/api/rms"));
    host(initdata.getString("host", "0.0.0.0"));
    port(cast(ushort)initdata.getInteger("port", 8095));
    
    // Service metadata
    serviceName(initdata.getString("serviceName", "uim-rms"));
    serviceVersion(initdata.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBool("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  string dataDirectory = "/tmp/uim-rms-data";
  string defaultTenant = "provider";
  string defaultSpace = "dev";

  int logRetention = 500;

  override void validate() const {
    super.validate();

    if (dataDirectory.length == 0) {
      throw new RMSConfigurationException("Data directory cannot be empty");
    }
    if (defaultTenant.length == 0 || defaultSpace.length == 0) {
      throw new RMSConfigurationException("Default tenant and space are required");
    }
    if (logRetention < 50) {
      throw new RMSConfigurationException("Log retention must be at least 50");
    }
  }
}
