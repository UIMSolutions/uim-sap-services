module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.sdi;

void main() {
    SDIConfig config;
    config.host = envOr("SDI_HOST", "0.0.0.0");
    config.port = readPort(envOr("SDI_PORT", "8096"), 8096);
    config.basePath = envOr("SDI_BASE_PATH", "/api/sitedirectory");
    config.serviceName = envOr("SDI_SERVICE_NAME", "uim-sap-sdi");
    config.serviceVersion = envOr("SDI_SERVICE_VERSION", UIM_SDI_VERSION);

    auto token = envOr("SDI_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new SDIService(config);
    auto server = new SDIServer(service);

    writeln("Starting Site Directory service on ", config.host, ":", config.port);
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
