/**
 * Configuration for SCL Cloud Logging service
 */
module uim.sap.scl.config;

import std.string : startsWith;

import uim.sap.scl.exceptions;

struct SCLConfig {
    string host = "0.0.0.0";
    ushort port = 8081;
    string basePath = "/sap/cloud/logging/v1";

    string serviceName = "uim-sap-scl";
    string serviceVersion = "1.0.0";

    size_t maxEntries = 10000;
    size_t defaultQueryLimit = 100;

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new SCLConfigurationException("Host cannot be empty");
        }

        if (port == 0) {
            throw new SCLConfigurationException("Port must be greater than zero");
        }

        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new SCLConfigurationException("Base path must start with '/'");
        }

        if (maxEntries == 0) {
            throw new SCLConfigurationException("maxEntries must be greater than zero");
        }

        if (defaultQueryLimit == 0) {
            throw new SCLConfigurationException("defaultQueryLimit must be greater than zero");
        }

        if (requireAuthToken && authToken.length == 0) {
            throw new SCLConfigurationException("authToken is required when requireAuthToken is enabled");
        }
    }
}
