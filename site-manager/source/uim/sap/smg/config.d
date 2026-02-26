/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.smg.config;

import std.string : startsWith;

import uim.sap.smg.exceptions;

struct SMGConfig {
    string host = "0.0.0.0";
    ushort port = 8094;
    string basePath = "/api/sitemanager";

    string serviceName = "uim-sap-smg";
    string serviceVersion = "1.0.0";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) throw new SMGConfigurationException("Host cannot be empty");
        if (port == 0) throw new SMGConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/")) throw new SMGConfigurationException("Base path must start with '/'");
        if (serviceName.length == 0) throw new SMGConfigurationException("Service name cannot be empty");
        if (requireAuthToken && authToken.length == 0) throw new SMGConfigurationException("Auth token required when token auth is enabled");
    }
}
