module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import vibe.core.core : runApplication;
import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
void main() {
    FFConfig config = new FFConfig;
    config.host = envOr("FF_HOST", "0.0.0.0");
    config.port = readPort(envOr("FF_PORT", "8094"), 8094);
    config.basePath = envOr("FF_BASE_PATH", "/api/ff");
    config.serviceName = envOr("FF_SERVICE_NAME", "uim-sap-ff");
    config.serviceVersion = envOr("FF_SERVICE_VERSION", UIM_FF_VERSION);

    auto token = envOr("FF_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new FFService(config);
    auto server = new FFServer(service);

    writeln("Starting Feature Flags service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
}}

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
