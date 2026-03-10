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

    /// Maximum number of buckets
    size_t maxBuckets = 500;

    /// Maximum objects per bucket
    size_t maxObjectsPerBucket = 50_000;

    /// Maximum object size in bytes (default 100 MB)
    size_t maxObjectSizeBytes = 104_857_600;

    /// Maximum bucket size in bytes (default 10 GB)
    size_t maxBucketSizeBytes = 10_737_418_240;

    /// Default storage provider
    string defaultProvider = "aws-s3";

    /// Default region
    string defaultRegion = "eu-central-1";

    /// Enable versioning by default
    bool defaultVersioning = false;

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
        if (maxBuckets == 0)
            throw new OBSConfigurationException("maxBuckets must be greater than zero");
        if (maxObjectSizeBytes == 0)
            throw new OBSConfigurationException("maxObjectSizeBytes must be greater than zero");
    }
}
