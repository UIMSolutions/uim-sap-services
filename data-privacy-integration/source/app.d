module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.dpi;

void main() {
    DPIConfig config;
    config.host = envOr("DPI_HOST", "0.0.0.0");
    config.port = readPort(envOr("DPI_PORT", "8093"), 8093);
    config.basePath = envOr("DPI_BASE_PATH", "/api/dpi");
    config.serviceName = envOr("DPI_SERVICE_NAME", "uim-sap-dpi");
    config.serviceVersion = envOr("DPI_SERVICE_VERSION", UIM_DPI_VERSION);
    config.defaultRetentionDays = readInt(envOr("DPI_DEFAULT_RETENTION_DAYS", "365"), 365);

    auto token = envOr("DPI_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new DPIService(config);
    auto server = new DPIServer(service);

    writeln("Starting DPI service on ", config.host, ":", config.port);
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
