module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import vibe.core.core : runApplication;

import uim.sap.tc;

void main() {
    TCConfig config;
    config.host = envOr("TC_HOST", "0.0.0.0");
    config.port = readPort(envOr("TC_PORT", "8096"), 8096);
    config.basePath = envOr("TC_BASE_PATH", "/api/task-center");
    config.serviceName = envOr("TC_SERVICE_NAME", "uim-sap-task-center");
    config.serviceVersion = envOr("TC_SERVICE_VERSION", UIM_TC_VERSION);
    config.dataDirectory = envOr("TC_DATA_DIR", "/tmp/uim-task-center-data");
    config.cacheFileName = envOr("TC_CACHE_FILE", "task-cache.json");

    auto token = envOr("TC_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new TCService(config);
    auto server = new TCServer(service);

    writeln("Starting Task Center service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    writeln("Data directory: ", config.dataDirectory);
    server.run();
    runApplication();
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
