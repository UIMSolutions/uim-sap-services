module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.clg;

void main() {
    CLGConfig config;
    config.host = envOr("CLG_HOST", "127.0.0.1");
    config.port = readPort(envOr("CLG_PORT", "8081"), 8081);
    config.basePath = envOr("CLG_BASE_PATH", "/uim/cloud/logging/v1");
    config.serviceName = envOr("CLG_SERVICE_NAME", "uim-sap-clg");
    config.serviceVersion = envOr("CLG_SERVICE_VERSION", UIM_SAP_CLG_VERSION);
    config.maxEntries = readSize(envOr("CLG_MAX_ENTRIES", "10000"), 10000);
    config.defaultQueryLimit = readSize(envOr("CLG_DEFAULT_QUERY_LIMIT", "100"), 100);

    auto token = envOr("CLG_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new CLGService(config);
    auto server = new CLGServer(service);

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
