module app;

import std.conv    : to;
import std.process : environment;
import std.stdio   : writeln;

import uim.sap.cia;

void main()
{
    CIAConfig config;
    config.host           = envOr("CIA_HOST",            "0.0.0.0");
    config.port           = readPort(envOr("CIA_PORT",   "8098"), 8098);
    config.basePath       = envOr("CIA_BASE_PATH",       "/api/cloud-integration-automation");
    config.serviceName    = envOr("CIA_SERVICE_NAME",    "uim-sap-cloud-integration-automation");
    config.serviceVersion = envOr("CIA_SERVICE_VERSION", UIM_CIA_VERSION);
    config.runtime        = envOr("CIA_RUNTIME",         "cloud-foundry");

    auto token = envOr("CIA_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken        = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new CIAService(config);
    auto server  = new CIAServer(service);

    writeln("Starting Cloud Integration Automation service on ", config.host, ":", config.port);
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
