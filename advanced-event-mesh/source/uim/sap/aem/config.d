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

    host(initData.getString("host", "0.0.0.0"));
    serviceName(initData.getString("serviceName", "uim-aem"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));
    return true;
  }

  ushort port = 8088;
  string basePath = "/api/aem";
  string defaultMeshRegion = "eu10";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (defaultMeshRegion.length == 0) {
      throw new AEMConfigurationException("Default mesh region cannot be empty");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new AEMConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
