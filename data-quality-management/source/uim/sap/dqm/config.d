module uim.sap.dqm.config;

import std.string : startsWith;

import uim.sap.dqm.exceptions;

struct DQMConfig {
    string host = "0.0.0.0";
    ushort port = 8091;
    string basePath = "/api/dqm";

    string serviceName = "uim-sap-dqm";
    string serviceVersion = "1.0.0";
    string defaultCountry = "DE";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) throw new DQMConfigurationException("Host cannot be empty");
        if (port == 0) throw new DQMConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/")) throw new DQMConfigurationException("Base path must start with '/'");
        if (serviceName.length == 0) throw new DQMConfigurationException("Service name cannot be empty");
        if (defaultCountry.length == 0) throw new DQMConfigurationException("Default country cannot be empty");
        if (requireAuthToken && authToken.length == 0) throw new DQMConfigurationException("Auth token required when token auth is enabled");
    }
}
