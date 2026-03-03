module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;
import std.string : toLower;

import uim.sap.documentmanagement;

version (unittest) {
} else {
void main() {
    DocumentManagementConfig config;
    config.host = envOr("DMS_HOST", "0.0.0.0");
    config.port = readPort(envOr("DMS_PORT", "8090"), 8090);
    config.basePath = envOr("DMS_BASE_PATH", "/api/docmgmt");
    config.serviceName = envOr("DMS_SERVICE_NAME", "uim-sap-document-management");
    config.serviceVersion = envOr("DMS_SERVICE_VERSION", UIM_DOCUMENT_MANAGEMENT_VERSION);
    config.maxUploadSizeMB = readInt(envOr("DMS_MAX_UPLOAD_SIZE_MB", "100"), 100);
    config.defaultRepository = envOr("DMS_DEFAULT_REPOSITORY", "internal");
    config.versioningEnabled = readBool(envOr("DMS_VERSIONING_ENABLED", "true"), true);
    config.encryptionEnabled = readBool(envOr("DMS_ENCRYPTION_ENABLED", "false"), false);

    auto encKey = envOr("DMS_ENCRYPTION_KEY", "");
    if (encKey.length > 0)
        config.encryptionKey = encKey;

    auto authToken = envOr("DMS_AUTH_TOKEN", "");
    if (authToken.length > 0) {
        config.requireAuthToken = true;
        config.authToken = authToken;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new DocumentManagementService(config);
    auto server = new DocumentManagementServer(service);

    writeln("Starting Document Management Service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    writeln("Default repository: ", config.defaultRepository);
    writeln("Versioning: ", config.versioningEnabled ? "enabled" : "disabled");
    writeln("Encryption: ", config.encryptionEnabled ? "enabled" : "disabled");
    server.run();
}
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

private bool readBool(string value, bool fallback) {
    auto lower = toLower(value);
    if (lower == "true" || lower == "1" || lower == "yes")
        return true;
    if (lower == "false" || lower == "0" || lower == "no")
        return false;
    return fallback;
}

private double readDouble(string value, double fallback) {
    try {
        return to!double(value);
    } catch (Exception) {
        return fallback;
    }
}
