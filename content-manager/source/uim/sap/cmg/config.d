/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cmg.config;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:
struct CMGConfig : SAPConfig {
  mixin(SAPConfigTemplate!CMGConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/cmg"));
    serviceName(initData.getString("serviceName", "uim-cmg"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  ushort port = 8095;

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (host.length == 0)
      throw new CMGConfigurationException("Host cannot be empty");
    if (port == 0)
      throw new CMGConfigurationException("Port must be greater than zero");
    if (basePath.length == 0 || !basePath.startsWith("/"))
      throw new CMGConfigurationException("Base path must start with '/'");
    if (serviceName.length == 0)
      throw new CMGConfigurationException("Service name cannot be empty");
    if (requireAuthToken && authToken.length == 0)
      throw new CMGConfigurationException("Auth token required when token auth is enabled");
  }
}
