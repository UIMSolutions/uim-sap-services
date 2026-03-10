/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.dpi.config;

import std.string : startsWith;

import uim.sap.dpi.exceptions;

struct DPIConfig : SAPConfig {
  mixin(SAPConfigTemplate!DPIConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/dpi"));
    serviceName(initData.getString("serviceName", "uim-dpi"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  ushort port = 8093;
  int defaultRetentionDays = 365;

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (host.length == 0)
      throw new DPIConfigurationException("Host cannot be empty");
    if (port == 0)
      throw new DPIConfigurationException("Port must be greater than zero");
    if (basePath.length == 0 || !basePath.startsWith("/"))
      throw new DPIConfigurationException("Base path must start with '/'");
    if (serviceName.length == 0)
      throw new DPIConfigurationException("Service name cannot be empty");
    if (defaultRetentionDays <= 0)
      throw new DPIConfigurationException("Default retention days must be greater than zero");
    if (requireAuthToken && authToken.length == 0)
      throw new DPIConfigurationException("Auth token required when token auth is enabled");
  }
}
