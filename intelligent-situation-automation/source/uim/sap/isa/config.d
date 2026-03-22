/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.isa.config;
import uim.sap.isa;

mixin(ShowModule!());

@safe:

class ISAConfig : SAPConfig {
  mixin(SAPConfigTemplate!ISAConfig);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network settings
    basePath(initData.getString("basePath", "/api/situation-automation"));
    port(cast(ushort)initData.getInteger("port", 8088));
    host(initData.getString("host", "0.0.0.0"));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-isa"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

  bool requireAuthToken = false;
  string authToken;

    return true;
  }

  string defaultTenant = "default";


  override void validate() {
    super.validate();

    if (defaultTenant.length == 0) {
      throw new ISAConfigurationException("Default tenant cannot be empty");
    }
  }
}
