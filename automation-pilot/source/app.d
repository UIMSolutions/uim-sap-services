module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.atp;

void main() {
    ATPConfig config;
    config.host = envOr("ATP_HOST", "0.0.0.0");
    config.port = readPort(envOr("ATP_PORT", "8097"), 8097);
    config.basePath = envOr("ATP_BASE_PATH", "/api/automation-pilot");
    config.serviceName = envOr("ATP_SERVICE_NAME", "uim-sap-atp");
    config.serviceVersion = envOr("ATP_SERVICE_VERSION", UIM_ATP_VERSION);
    config.aiProvider = envOr("ATP_AI_PROVIDER", "mock-genai");

    auto token = envOr("ATP_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new ATPService(config);
    auto server = new ATPServer(service);

    writeln("Starting Automation Pilot service on ", config.host, ":", config.port);
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
