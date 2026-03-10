module app;

import uim.sap.obs;

void main() {
    OBSConfig config;
    config.host = envOr("OBS_HOST", "0.0.0.0");
    config.port = readPort(envOr("OBS_PORT", "8091"), 8091);
    config.basePath = envOr("OBS_BASE_PATH", "/api/obs");
    config.serviceName = envOr("OBS_SERVICE_NAME", "uim-obs");
    config.serviceVersion = envOr("OBS_SERVICE_VERSION", UIM_OBS_VERSION);

    config.maxBuckets = readSize(envOr("OBS_MAX_BUCKETS", "500"), 500);
    config.maxObjectsPerBucket = readSize(envOr("OBS_MAX_OBJECTS_PER_BUCKET", "100000"), 100_000);
    config.maxObjectSizeBytes = readSize(envOr("OBS_MAX_OBJECT_SIZE", "104857600"), 104_857_600);
    config.maxBucketStorageBytes = readSize(envOr("OBS_MAX_BUCKET_STORAGE", "10737418240"), 10_737_418_240);
    config.defaultProvider = envOr("OBS_DEFAULT_PROVIDER", "aws");
    config.defaultRegion = envOr("OBS_DEFAULT_REGION", "eu-central-1");

    string verStr = envOr("OBS_DEFAULT_VERSIONING", "false");
    config.defaultVersioning = (verStr == "true" || verStr == "1");

    auto token = envOr("OBS_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new OBSService(config);
    auto server = new OBSServer(service);

    writeln("Starting Object Store Service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    writeln("Default provider: ", config.defaultProvider);
    writeln("Default region: ", config.defaultRegion);
    server.run();
}
