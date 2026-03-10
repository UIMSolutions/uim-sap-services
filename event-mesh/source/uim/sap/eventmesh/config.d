/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.eventmesh.config;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EVMConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8092;
    string basePath = "/api/em";
    string serviceName = "uim-em";
    string serviceVersion = "1.0.0";
    bool requireAuthToken = false;
    string authToken;
    string[string] customHeaders;

    void validate() {
        if (port == 0) {
            throw new EVMConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0) {
            throw new EVMConfigurationException("Base path cannot be empty");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new EVMConfigurationException("Auth token required but not set");
        }
    }
}
