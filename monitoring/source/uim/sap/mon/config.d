/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mon.config;

import uim.sap.mon;

mixin(ShowModule!());

@safe:

class MONConfig : SAPConfig {
  string host = "0.0.0.0";
  ushort port = 8090;
  string basePath = "/api/mon";

  string serviceName = "uim-mon";
  string serviceVersion = "1.0.0";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (host.length == 0) {
      throw new MONConfigurationException("Host cannot be empty");
    }
    if (port == 0) {
      throw new MONConfigurationException("Port must be greater than zero");
    }
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new MONConfigurationException("Base path must start with '/'");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new MONConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
