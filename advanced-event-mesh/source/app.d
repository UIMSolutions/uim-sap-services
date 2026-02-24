module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.aem;

void main() {
    AEMConfig config;
    config.host = envOr("AEM_HOST", "0.0.0.0");
    config.port = readPort(envOr("AEM_PORT", "8088"), 8088);
    config.basePath = envOr("AEM_BASE_PATH", "/api/aem");
    config.serviceName = envOr("AEM_SERVICE_NAME", "uim-sap-aem");
    config.serviceVersion = envOr("AEM_SERVICE_VERSION", UIM_SAP_AEM_VERSION);
    config.defaultMeshRegion = envOr("AEM_DEFAULT_REGION", "eu10");

    auto token = envOr("AEM_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new AEMService(config);
    auto server = new AEMServer(service);

    writeln("Starting AEM service on ", config.host, ":", config.port);
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
