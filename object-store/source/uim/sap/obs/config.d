module uim.sap.obs.config;

import uim.sap.obs;

mixin(ShowModule!());

@safe:

struct OBSConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8091;
    string basePath = "/api/obs";

    string serviceName = "uim-obs";
    string serviceVersion = "1.0.0";

    bool requireAuthToken = false;
    string authToken;

    /// Maximum buckets per tenant
    size_t maxBucketsPerTenant = 100;

    /// Maximum objects per bucket
    size_t maxObjectsPerBucket = 100_000;

    /// Maximum object size in bytes (default 5 GiB)
    size_t maxObjectSizeBytes = 5L * 1024 * 1024 * 1024;

    /// Maximum multipart upload parts
    size_t maxMultipartParts = 10_000;

    /// Default storage replication factor
    size_t replicationFactor = 3;

    /// Credential expiry in seconds
    size_t credentialExpirySecs = 3600;

    string[string] customHeaders;

    void validate() const {
        super.validate();

        if (host.length == 0)
            throw new OBSConfigurationException("Host cannot be empty");
        if (port == 0)
            throw new OBSConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/"))
            throw new OBSConfigurationException("Base path must start with '/'");
        if (requireAuthToken && authToken.length == 0)
            throw new OBSConfigurationException("Auth token required when token auth is enabled");
        if (maxBucketsPerTenant == 0)
            throw new OBSConfigurationException("maxBucketsPerTenant must be greater than zero");
    }
}
