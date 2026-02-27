module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.isa;

void main() {
    ISAConfig config;
    config.host = envOr("ISA_HOST", "0.0.0.0");
    config.port = readPort(envOr("ISA_PORT", "8088"), 8088);
    config.basePath = envOr("ISA_BASE_PATH", "/api/situation-automation");
    config.serviceName = envOr("ISA_SERVICE_NAME", "uim-sap-isa");
    config.serviceVersion = envOr("ISA_SERVICE_VERSION", UIM_SAP_ISA_VERSION);

    config.defaultTenant = envOr("ISA_DEFAULT_TENANT", "default");

    auto token = envOr("ISA_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new ISAService(config);
    auto server = new ISAServer(service);

    writeln("Starting Intelligent Situation Automation service on ", config.host, ":", config.port);
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
