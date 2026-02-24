module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.clf;

void main() {
    CLFConfig config;
    config.host = envOr("CLF_HOST", "0.0.0.0");
    config.port = readPort(envOr("CLF_PORT", "8082"), 8082);
    config.basePath = envOr("CLF_BASE_PATH", "/api/cf");
    config.serviceName = envOr("CLF_SERVICE_NAME", "uim-sap-clf");
    config.serviceVersion = envOr("CLF_SERVICE_VERSION", UIM_SAP_CLF_VERSION);

    auto token = envOr("CLF_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new CLFService(config);
    auto server = new CLFServer(service);

    writeln("Starting CLF service on ", config.host, ":", config.port);
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
