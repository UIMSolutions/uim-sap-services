/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.tkc.config;

import uim.sap.tkc;

mixin(ShowModule!());

@safe:

class TKCConfig : SAPConfig {
  mixin(SAPConfigTemplate!TKCConfig);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
       return false;
    }

  port(cast(ushort)initData.getInteger("port", 8096));
  host(initData.getString("host", "0.0.0.0"));
  basePath(initData.getString("basePath", "/api/task-center"));
  serviceName(initData.getString("serviceName", "uim-task-center"));
  serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  string dataDirectory = "/tmp/uim-task-center-data";
  string cacheFileName = "task-cache.json";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  @property string cacheFilePath() const {
    return buildPath(dataDirectory, cacheFileName);
  }

  override void validate() const {
    super.validate();

    if (dataDirectory.length == 0)
      throw new TKCConfigurationException("Data directory cannot be empty");
    if (cacheFileName.length == 0)
      throw new TKCConfigurationException("Cache file name cannot be empty");
    if (requireAuthToken && authToken.length == 0) {
      throw new TKCConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
