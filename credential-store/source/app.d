module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.cre;

void main() {
    CREConfig config;
    config.host = envOr("CRE_HOST", "0.0.0.0");
    config.port = readPort(envOr("CRE_PORT", "8086"), 8086);
    config.basePath = envOr("CRE_BASE_PATH", "/api/cre");
    config.serviceName = envOr("CRE_SERVICE_NAME", "uim-sap-cre");
    config.serviceVersion = envOr("CRE_SERVICE_VERSION", UIM_CRE_VERSION);
    config.masterKey = envOr("CRE_MASTER_KEY", "uim-sap-cre-dev-master-key");

    auto token = envOr("CRE_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new CREService(config);
    auto server = new CREServer(service);

    writeln("Starting CRE service on ", config.host, ":", config.port);
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
