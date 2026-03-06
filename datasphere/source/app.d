module app;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:

void main() {
    DatasphereConfig config  = new DatasphereConfig();
    config.host = envOr("DATASPHERE_HOST", "0.0.0.0");
    config.port = readPort(envOr("DATASPHERE_PORT", "8098"), 8098);
    config.basePath = envOr("DATASPHERE_BASE_PATH", "/api/datasphere");
    config.serviceName = envOr("DATASPHERE_SERVICE_NAME", "uim-sap-datasphere");
    config.serviceVersion = envOr("DATASPHERE_SERVICE_VERSION", UIM_DATASPHERE_VERSION);
    config.defaultSpaceDiskGb = readInt(envOr("DATASPHERE_DEFAULT_SPACE_DISK_GB", "50"), 50);
    config.defaultSpaceMemoryGb = readInt(envOr("DATASPHERE_DEFAULT_SPACE_MEMORY_GB", "16"), 16);

    auto token = envOr("DATASPHERE_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new DatasphereService(config);
    auto server = new DatasphereServer(service);

    writeln("Starting Datasphere service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
}

private string envOr(string key, string fallback) {
    auto value = environment.get(key, "");
    return value.length > 0 ? value : fallback;
}

private ushort readPort(string value, ushort fallback) {
    try {
        auto parsed = to!ushort(value);
        return parsed > 0 ? parsed : fallback;
    } catch (Exception) {
        return fallback;
    }
}

private int readInt(string value, int fallback) {
    try {
        auto parsed = to!int(value);
        return parsed > 0 ? parsed : fallback;
    } catch (Exception) {
        return fallback;
    }
}
