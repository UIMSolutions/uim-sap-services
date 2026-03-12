/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.identityprovisioning.config;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

class IPVConfig : SAPConfig {
    override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
       return false;
    }

    basePath(initdata.getString("basePath", "/api/ip"));
    host(initdata.getString("host", "0.0.0.0"));
    port(initdata.get("port", 8095));
    serviceName(initdata.getString("serviceName", "uim-ip"));
    serviceVersion(initdata.getString("serviceVersion", "1.0.0"));

    return true;
  } 
    bool requireAuthToken = false;
    string authToken;
    string[string] customHeaders;

    void validate() {
        if (port == 0) {
            throw new IPVConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0) {
            throw new IPVConfigurationException("Base path cannot be empty");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new IPVConfigurationException("Auth token required but not set");
        }
    }
}
