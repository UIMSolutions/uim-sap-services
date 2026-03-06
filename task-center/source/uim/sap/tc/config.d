/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.tkc.config;

import uim.sap.tkc;

struct TCConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8096;
    string basePath = "/api/task-center";

    string serviceName = "uim-sap-task-center";
    string serviceVersion = "1.0.0";

    string dataDirectory = "/tmp/uim-task-center-data";
    string cacheFileName = "task-cache.json";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    @property string cacheFilePath() const {
        return buildPath(dataDirectory, cacheFileName);
    }

    void validate() const {
        if (host.length == 0) throw new TCConfigurationException("Host cannot be empty");
        if (port == 0) throw new TCConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new TCConfigurationException("Base path must start with '/'");
        }
        if (serviceName.length == 0) throw new TCConfigurationException("Service name cannot be empty");
        if (dataDirectory.length == 0) throw new TCConfigurationException("Data directory cannot be empty");
        if (cacheFileName.length == 0) throw new TCConfigurationException("Cache file name cannot be empty");
        if (requireAuthToken && authToken.length == 0) {
            throw new TCConfigurationException("Auth token required when token auth is enabled");
        }
    }
}
