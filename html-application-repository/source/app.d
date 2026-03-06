module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;
import std.string : toLower;

import uim.sap.html5repo;

void main() {
    HTMRepoConfig config;
    config.host = envOr("HTM_REPO_HOST", "0.0.0.0");
    config.port = readPort(envOr("HTM_REPO_PORT", "8094"), 8094);
    config.basePath = envOr("HTM_REPO_BASE_PATH", "/api/html5-repo");
    config.serviceName = envOr("HTM_REPO_SERVICE_NAME", "uim-sap-html5-app-repo");
    config.serviceVersion = envOr("HTM_REPO_SERVICE_VERSION", UIM_HTM_REPO_VERSION);
    config.dataDirectory = envOr("HTM_REPO_DATA_DIR", "/tmp/uim-html5-repo-data");
    config.defaultTenant = envOr("HTM_REPO_DEFAULT_TENANT", "provider");
    config.defaultSpace = envOr("HTM_REPO_DEFAULT_SPACE", "dev");
    config.allowPublicCrossSpace = toLower(envOr("HTM_REPO_ALLOW_PUBLIC_CROSS_SPACE", "true")) == "true";
    config.cacheTtlSeconds = readInt(envOr("HTM_REPO_CACHE_TTL_SECONDS", "120"), 120);
    config.maxUploadBytes = readLong(envOr("HTM_REPO_MAX_UPLOAD_BYTES", "52428800"), 52_428_800L);

    auto token = envOr("HTM_REPO_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireManagementAuth = true;
        config.managementAuthToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new HTMRepoService(config);
    auto server = new HTMRepoServer(service);

    writeln("Starting HTM Repository service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    writeln("Data directory: ", config.dataDirectory);
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

private long readLong(string value, long fallback) {
    try {
        return to!long(value);
    } catch (Exception) {
        return fallback;
    }
}
