module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.cis;

void main() {
    CISConfig config;
    config.host = envOr("CIS_HOST", "0.0.0.0");
    config.port = readPort(envOr("CIS_PORT", "8088"), 8088);
    config.basePath = envOr("CIS_BASE_PATH", "/api/cis");
    config.serviceName = envOr("CIS_SERVICE_NAME", "uim-sap-cis");
    config.serviceVersion = envOr("CIS_SERVICE_VERSION", UIM_SAP_CIS_VERSION);
    config.defaultAuthMethod = envOr("CIS_DEFAULT_AUTH_METHOD", "form");

    auto token = envOr("CIS_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new CISService(config);
    auto server = new CISServer(service);

    writeln("Starting CIS service on ", config.host, ":", config.port);
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
