module app;

import std.conv    : to;
import std.process : environment;
import std.stdio   : writeln;

import uim.sap.dst;

void main() {
    DSTConfig config;
    config.host           = envOr("DST_HOST",            "0.0.0.0");
    config.port           = readPort(envOr("DST_PORT",   "8104"), 8104);
    config.basePath       = envOr("DST_BASE_PATH",       "/api/destination");
    config.serviceName    = envOr("DST_SERVICE_NAME",    "uim-sap-dst");
    config.serviceVersion = envOr("DST_SERVICE_VERSION", UIM_DST_VERSION);
    config.runtime        = envOr("DST_RUNTIME",         "cloud-foundry");

    auto token = envOr("DST_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken        = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new DSTService(config);
    auto server  = new DSTServer(service);

    writeln("Starting Destination service on ", config.host, ":", config.port);
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
