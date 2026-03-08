/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aas.config;

import uim.sap.aas;

@safe:

class AASConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8086;
    string basePath = "/api/autoscaler";

    string serviceName = "uim-sap-aas";
    string serviceVersion = "1.0.0";

    string cfApi;
    string cfOrganization;
    string cfSpace;

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new AASConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new AASConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new AASConfigurationException("Base path must start with '/'");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new AASConfigurationException("Auth token required when token auth is enabled");
        }
    }
}
