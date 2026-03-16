/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.config;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

/**
  * Configuration class for the Agentry service.
  * 
  * This class extends the base SAPConfig and adds specific configuration parameters
  * for the Agentry service, such as network settings, service metadata, and authentication options.
  *
  * It also includes validation logic to ensure that the configuration is correct before the service starts.
  */
class AGTConfig : SAPConfig {
  mixin(SAPConfigTemplate!AGTConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    basePath(initData.getString("basePath", "/api/agentry"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8089));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-agentry"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  string defaultBackendSystem = "s4-primary";

  override void validate() {
    super.validate();

    if (defaultBackendSystem.length == 0) {
      throw new AGTConfigurationException("Default backend system cannot be empty");
    }
  }
}
