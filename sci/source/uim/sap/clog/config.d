/**
 * Configuration for SCI Cloud Logging service
 */
module uim.sap.clog.config;

import std.string : startsWith;

import uim.sap.clog.exceptions;

struct SCIConfig {
    string host = "0.0.0.0";
    ushort port = 8081;
    string basePath = "/sap/cloud/logging/v1";

    string serviceName = "uim-sap-sci";
    string serviceVersion = "1.0.0";

    size_t maxEntries = 10000;
    size_t defaultQueryLimit = 100;

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new SCIConfigurationException("Host cannot be empty");
        }

        if (port == 0) {
            throw new SCIConfigurationException("Port must be greater than zero");
        }

        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new SCIConfigurationException("Base path must start with '/'");
        }

        if (maxEntries == 0) {
            throw new SCIConfigurationException("maxEntries must be greater than zero");
        }

        if (defaultQueryLimit == 0) {
            throw new SCIConfigurationException("defaultQueryLimit must be greater than zero");
        }

        if (requireAuthToken && authToken.length == 0) {
            throw new SCIConfigurationException("authToken is required when requireAuthToken is enabled");
        }
    }
}
