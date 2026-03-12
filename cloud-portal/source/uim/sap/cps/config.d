/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cps.config;

import uim.sap.cps;

mixin(ShowModule!());

@safe:

class CPSConfig : SAPConfig {
  mixin(SAPConfigTemplate!CPSConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8089));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/cps"));
    serviceName(initData.getString("serviceName", "uim-cps"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  string defaultTheme = "sap_fiori_3";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (defaultTheme.length == 0) {
      throw new CPSConfigurationException("Default theme cannot be empty");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new CPSConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
