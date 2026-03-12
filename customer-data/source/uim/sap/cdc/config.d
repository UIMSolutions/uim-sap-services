/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cdc.config;

import std.path : buildPath;
import std.string : startsWith;

import uim.sap.cdc.exceptions;

class CDCConfig : SAPConfig {
  mixin(SAPConfigTemplate!CDCConfig);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    /// Network
    basePath(initData.getString("basePath", "/api/customer-data"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8097));

    /// Service metadata
    serviceName(initData.getString("serviceName", "uim-customer-data"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

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
