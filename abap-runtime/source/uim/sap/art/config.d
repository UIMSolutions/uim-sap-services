/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.art.config;

import core.time : Duration, seconds;
import std.string : startsWith;

import uim.sap.art.exceptions;

struct ARTRuntimeConfig : SAPConfig {
    string host = "127.0.0.1";
    ushort port = 8080;
    string basePath = "/sap/abap/runtime";

    string runtimeName = "uim-art";
    string runtimeVersion = "1.0.0";

    Duration requestTimeout = 30.seconds;
    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new ARTRuntimeConfigurationException("Host cannot be empty");
        }

        if (port == 0) {
            throw new ARTRuntimeConfigurationException("Port must be greater than zero");
        }

        if (basePath.length == 0) {
            throw new ARTRuntimeConfigurationException("Base path cannot be empty");
        }

        if (!basePath.startsWith("/")) {
            throw new ARTRuntimeConfigurationException("Base path must start with '/'");
        }

        if (requireAuthToken && authToken.length == 0) {
            throw new ARTRuntimeConfigurationException(
                "Auth token is required when requireAuthToken is enabled"
            );
        }
    }
}
