/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.sdi.config;

import uim.sap.sdi;

mixin(ShowModule!());

@safe:

class SDIConfig : SAPConfig {
  mixin(SAPConfigTemplate!SDIConfig);

  override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
       return false;
    }

    port(cast(ushort)initdata.getInteger("port", 8096));
    host(initdata.getString("host", "0.0.0.0"));
    basePath(initdata.getString("basePath", "/api/sitedirectory"));
    serviceName(initdata.getString("serviceName", "uim-sdi"));
    serviceVersion(initdata.getString("serviceVersion", "1.0.0"));

    return true;
  }

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (requireAuthToken && authToken.length == 0)
      throw new SDIConfigurationException("Auth token required when token auth is enabled");
  }
}
