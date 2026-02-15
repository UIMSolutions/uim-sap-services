module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.buh;

void main() {
    BUHConfig config;
    config.host = envOr("BUH_HOST", "0.0.0.0");
    config.port = readPort(envOr("BUH_PORT", "8083"), 8083);
    config.basePath = envOr("BUH_BASE_PATH", "/api/hub");
    config.serviceName = envOr("BUH_SERVICE_NAME", "uim-sap-buh");
    config.serviceVersion = envOr("BUH_SERVICE_VERSION", UIM_SAP_BUH_VERSION);

    auto token = envOr("BUH_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new BUHService(config);
    auto server = new BUHServer(service);

    writeln("Starting BUH service on ", config.host, ":", config.port);
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
