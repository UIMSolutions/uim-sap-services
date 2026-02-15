/**
 * Configuration for SAP ABAP Runtime (ART)
 */
module uim.sap.art.config;

import core.time : Duration, seconds;
import std.string : startsWith;

import uim.sap.art.exceptions;

struct SAPABAPRuntimeConfig {
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
            throw new SAPABAPRuntimeConfigurationException("Host cannot be empty");
        }

        if (port == 0) {
            throw new SAPABAPRuntimeConfigurationException("Port must be greater than zero");
        }

        if (basePath.length == 0) {
            throw new SAPABAPRuntimeConfigurationException("Base path cannot be empty");
        }

        if (!basePath.startsWith("/")) {
            throw new SAPABAPRuntimeConfigurationException("Base path must start with '/'");
        }

        if (requireAuthToken && authToken.length == 0) {
            throw new SAPABAPRuntimeConfigurationException(
                "Auth token is required when requireAuthToken is enabled"
            );
        }
    }
}
