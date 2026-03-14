/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.config;

import uim.sap.aem;

mixin(ShowModule!());

@safe:
class AEMConfig : SAPConfig {
  mixin(SAPConfigTemplate!AEMConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8088));
    basePath(initData.getString("basePath", "/api/aem"));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-aem"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  string defaultMeshRegion = "eu10";

  override void validate() {
    super.validate();

    if (defaultMeshRegion.length == 0) {
      throw new AEMConfigurationException("Default mesh region cannot be empty");
    }
  }
}
