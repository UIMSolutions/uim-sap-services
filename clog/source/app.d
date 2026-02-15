module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.scl;

void main() {
    SCLConfig config;
    config.host = envOr("SCL_HOST", "0.0.0.0");
    config.port = readPort(envOr("SCL_PORT", "8081"), 8081);
    config.basePath = envOr("SCL_BASE_PATH", "/uim/cloud/logging/v1");
    config.serviceName = envOr("SCL_SERVICE_NAME", "uim-sap-scl");
    config.serviceVersion = envOr("SCL_SERVICE_VERSION", UIM_SAP_SCL_VERSION);
    config.maxEntries = readSize(envOr("SCL_MAX_ENTRIES", "10000"), 10000);
    config.defaultQueryLimit = readSize(envOr("SCL_DEFAULT_QUERY_LIMIT", "100"), 100);

    auto token = envOr("SCL_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new SCLService(config);
    auto server = new SCLServer(service);

    writeln("Starting Cloud Logging service on ", config.host, ":", config.port);
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

private size_t readSize(string value, size_t fallback) {
    try {
        auto parsed = to!size_t(value);
        return parsed > 0 ? parsed : fallback;
    } catch (Exception) {
        return fallback;
    }
}
