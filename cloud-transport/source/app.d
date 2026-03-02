module app;

import std.conv    : to;
import std.process : environment;
import std.stdio   : writeln;

import uim.sap.ctm;

void main() {
    CTMConfig config;
    config.host           = envOr("CTM_HOST",            "0.0.0.0");
    config.port           = readPort(envOr("CTM_PORT",   "8100"), 8100);
    config.basePath       = envOr("CTM_BASE_PATH",       "/api/cloud-transport");
    config.serviceName    = envOr("CTM_SERVICE_NAME",    "uim-sap-ctm");
    config.serviceVersion = envOr("CTM_SERVICE_VERSION", UIM_CTM_VERSION);
    config.runtime        = envOr("CTM_RUNTIME",         "cloud-foundry");

    auto token = envOr("CTM_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken        = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new CTMService(config);
    auto server  = new CTMServer(service);

    writeln("Starting Cloud Transport Management service on ", config.host, ":", config.port);
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
