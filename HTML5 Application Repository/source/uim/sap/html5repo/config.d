module uim.sap.html5repo.config;

import std.string : startsWith;

import uim.sap.html5repo.exceptions;

struct HTML5RepoConfig {
    string host = "0.0.0.0";
    ushort port = 8094;
    string basePath = "/api/html5-repo";

    string serviceName = "uim-sap-html5-app-repo";
    string serviceVersion = "1.0.0";

    string dataDirectory = "/tmp/uim-html5-repo-data";
    string defaultTenant = "provider";
    string defaultSpace = "dev";

    bool requireManagementAuth = false;
    string managementAuthToken;

    bool allowPublicCrossSpace = true;
    int cacheTtlSeconds = 120;
    long maxUploadBytes = 52_428_800L;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) throw new HTML5RepoConfigurationException("Host cannot be empty");
        if (port == 0) throw new HTML5RepoConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/")) throw new HTML5RepoConfigurationException("Base path must start with '/'");
        if (serviceName.length == 0) throw new HTML5RepoConfigurationException("Service name cannot be empty");
        if (dataDirectory.length == 0) throw new HTML5RepoConfigurationException("Data directory cannot be empty");
        if (defaultTenant.length == 0) throw new HTML5RepoConfigurationException("Default tenant cannot be empty");
        if (defaultSpace.length == 0) throw new HTML5RepoConfigurationException("Default space cannot be empty");
        if (cacheTtlSeconds < 0) throw new HTML5RepoConfigurationException("Cache TTL must be >= 0");
        if (maxUploadBytes < 1) throw new HTML5RepoConfigurationException("maxUploadBytes must be positive");
        if (requireManagementAuth && managementAuthToken.length == 0) {
            throw new HTML5RepoConfigurationException("Management auth token is required when management auth is enabled");
        }
    }
}
