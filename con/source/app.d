module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.con;

void main() {
    CONConfig config;
    config.host = envOr("CON_HOST", "0.0.0.0");
    config.port = readPort(envOr("CON_PORT", "8085"), 8085);
    config.basePath = envOr("CON_BASE_PATH", "/api/con");
    config.serviceName = envOr("CON_SERVICE_NAME", "uim-sap-con");
    config.serviceVersion = envOr("CON_SERVICE_VERSION", UIM_SAP_CON_VERSION);
    config.connectorLocationId = envOr("CON_CONNECTOR_LOCATION_ID", "default-location");

    auto token = envOr("CON_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new CONService(config);
    auto server = new CONServer(service);

    writeln("Starting Connectivity service on ", config.host, ":", config.port);
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
