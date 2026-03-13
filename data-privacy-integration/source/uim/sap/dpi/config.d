/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.dpi.config;

import uim.sap.dpi;

mixin(ShowModule!());

@safe:

class DPIConfig : SAPConfig {
  mixin(SAPConfigTemplate!DPIConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    /// Network configuration
    basePath(initData.getString("basePath", "/api/dpi"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8093));

    /// Service metadata
    serviceName(initData.getString("serviceName", "uim-dpi"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBool("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  int defaultRetentionDays = 365;

  override void validate() const {
    super.validate();

    if (defaultRetentionDays <= 0) {
      throw new DPIConfigurationException("Default retention days must be greater than zero");
    }
  }
}
