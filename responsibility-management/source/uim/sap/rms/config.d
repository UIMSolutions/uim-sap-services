/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.rms.config;

import uim.sap.rms;

mixin(ShowModule!());

@safe:

struct RMSConfig : SAPConfig {
  string host = "0.0.0.0";
  ushort port = 8095;
  string basePath = "/api/rms";

  string serviceName = "uim-rms";
  string serviceVersion = "1.0.0";

  string dataDirectory = "/tmp/uim-rms-data";
  string defaultTenant = "provider";
  string defaultSpace = "dev";

  bool requireManagementAuth = false;
  string managementAuthToken;

  int logRetention = 500;

  string[string] customHeaders;

  void validate() const {
    super.validate();

    if (host.length == 0) {
      throw new RMSConfigurationException("Host cannot be empty");
    }
    if (port == 0) {
      throw new RMSConfigurationException("Port must be greater than zero");
    }
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new RMSConfigurationException("Base path must start with '/'");
    }
    if (serviceName.length == 0) {
      throw new RMSConfigurationException("Service name cannot be empty");
    }
    if (dataDirectory.length == 0) {
      throw new RMSConfigurationException("Data directory cannot be empty");
    }
    if (defaultTenant.length == 0 || defaultSpace.length == 0) {
      throw new RMSConfigurationException("Default tenant and space are required");
    }
    if (logRetention < 50) {
      throw new RMSConfigurationException("Log retention must be at least 50");
    }
    if (requireManagementAuth && managementAuthToken.length == 0) {
      throw new RMSConfigurationException("Management auth token is required");
    }
  }
}
