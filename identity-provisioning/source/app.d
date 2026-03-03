module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import vibe.core.core : runApplication;
import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
void main() {
    IPConfig config = new IPConfig;
    config.host = envOr("IP_HOST", "0.0.0.0");
    config.port = readPort(envOr("IP_PORT", "8095"), 8095);
    config.basePath = envOr("IP_BASE_PATH", "/api/ip");
    config.serviceName = envOr("IP_SERVICE_NAME", "uim-sap-ip");
    config.serviceVersion = envOr("IP_SERVICE_VERSION", UIM_IP_VERSION);

    auto token = envOr("IP_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new IPService(config);
    auto server = new IPServer(service);

    writeln("Starting Identity Provisioning service on ", config.host, ":", config.port);
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
