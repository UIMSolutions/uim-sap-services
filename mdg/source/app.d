module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.mdg;

void main() {
    MDGConfig config;
    config.host = envOr("MDG_HOST", "0.0.0.0");
    config.port = readPort(envOr("MDG_PORT", "8087"), 8087);
    config.basePath = envOr("MDG_BASE_PATH", "/api/mdg");
    config.serviceName = envOr("MDG_SERVICE_NAME", "uim-sap-mdg");
    config.serviceVersion = envOr("MDG_SERVICE_VERSION", UIM_SAP_MDG_VERSION);
    config.defaultApprover = envOr("MDG_DEFAULT_APPROVER", "mdg-approver");

    auto token = envOr("MDG_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new MDGService(config);
    auto server = new MDGServer(service);

    writeln("Starting MDG service on ", config.host, ":", config.port);
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
