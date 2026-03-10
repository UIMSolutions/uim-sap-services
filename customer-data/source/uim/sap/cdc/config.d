/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cdc.config;

import std.path : buildPath;
import std.string : startsWith;

import uim.sap.cdc.exceptions;

struct CDCConfig : SAPConfig {
  string host = "0.0.0.0";
  ushort port = 8097;
  string basePath = "/api/customer-data";

  string serviceName = "uim-customer-data";
  string serviceVersion = "1.0.0";

  string dataDirectory = "/tmp/uim-customer-data";
  string cacheFileName = "customer-data-cache.json";
  string defaultRegion = "eu-central";

  bool requireAuthToken = false;
  string authToken;

  @property string cacheFilePath() const {
    return buildPath(dataDirectory, cacheFileName);
  }

  override void validate() const {
    super.validate();

    if (host.length == 0)
      throw new CDCConfigurationException("Host cannot be empty");
    if (port == 0)
      throw new CDCConfigurationException("Port must be greater than zero");
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new CDCConfigurationException("Base path must start with '/'");
    }
    if (serviceName.length == 0)
      throw new CDCConfigurationException("Service name cannot be empty");
    if (dataDirectory.length == 0)
      throw new CDCConfigurationException("Data directory cannot be empty");
    if (cacheFileName.length == 0)
      throw new CDCConfigurationException("Cache file name cannot be empty");
    if (defaultRegion.length == 0)
      throw new CDCConfigurationException("Default region cannot be empty");
    if (requireAuthToken && authToken.length == 0) {
      throw new CDCConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
