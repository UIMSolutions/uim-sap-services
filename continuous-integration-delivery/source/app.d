module app;

import std.conv    : to;
import std.process : environment;
import std.stdio   : writeln;

import uim.sap.cid;

void main() {
    CIDConfig config;
    config.host           = envOr("CID_HOST",            "0.0.0.0");
    config.port           = readPort(envOr("CID_PORT",   "8102"), 8102);
    config.basePath       = envOr("CID_BASE_PATH",       "/api/cicd");
    config.serviceName    = envOr("CID_SERVICE_NAME",    "uim-sap-cid");
    config.serviceVersion = envOr("CID_SERVICE_VERSION", UIM_CID_VERSION);
    config.runtime        = envOr("CID_RUNTIME",         "cloud-foundry");

    auto token = envOr("CID_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken        = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new CIDService(config);
    auto server  = new CIDServer(service);

    writeln("Starting Continuous Integration & Delivery service on ", config.host, ":", config.port);
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
