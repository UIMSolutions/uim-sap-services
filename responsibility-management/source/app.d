module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.rms;

void main() {
    RMSConfig config;
    config.host = envOr("RMS_HOST", "0.0.0.0");
    config.port = readPort(envOr("RMS_PORT", "8095"), 8095);
    config.basePath = envOr("RMS_BASE_PATH", "/api/rms");
    config.serviceName = envOr("RMS_SERVICE_NAME", "uim-sap-rms");
    config.serviceVersion = envOr("RMS_SERVICE_VERSION", UIM_SAP_RMS_VERSION);
    config.dataDirectory = envOr("RMS_DATA_DIR", "/tmp/uim-rms-data");
    config.defaultTenant = envOr("RMS_DEFAULT_TENANT", "provider");
    config.defaultSpace = envOr("RMS_DEFAULT_SPACE", "dev");
    config.logRetention = readInt(envOr("RMS_LOG_RETENTION", "500"), 500);

    auto token = envOr("RMS_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireManagementAuth = true;
        config.managementAuthToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new RMSService(config);
    auto server = new RMSServer(service);

    writeln("Starting Responsibility Management service on ", config.host, ":", config.port);
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

private int readInt(string value, int fallback) {
    try {
        return to!int(value);
    } catch (Exception) {
        return fallback;
    }
}
