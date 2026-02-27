module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.cag;

void main() {
    CAGConfig config;
    config.host = envOr("CAG_HOST", "0.0.0.0");
    config.port = readPort(envOr("CAG_PORT", "8096"), 8096);
    config.basePath = envOr("CAG_BASE_PATH", "/api/content-agent");
    config.serviceName = envOr("CAG_SERVICE_NAME", "uim-sap-content-agent");
    config.serviceVersion = envOr("CAG_SERVICE_VERSION", UIM_SAP_CAG_VERSION);
    config.runtime = envOr("CAG_RUNTIME", "cloud-foundry");

    auto token = envOr("CAG_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new CAGService(config);
    auto server = new CAGServer(service);

    writeln("Starting Content Agent service on ", config.host, ":", config.port);
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
