module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.auditlog;

version (unittest) {
} else {
void main() {
    AuditLogConfig config;
    config.host = envOr("AUDITLOG_HOST", "0.0.0.0");
    config.port = readPort(envOr("AUDITLOG_PORT", "8090"), 8090);
    config.basePath = envOr("AUDITLOG_BASE_PATH", "/api/auditlog");
    config.serviceName = envOr("AUDITLOG_SERVICE_NAME", "uim-sap-audit-log");
    config.serviceVersion = envOr("AUDITLOG_SERVICE_VERSION", UIM_SAP_AUDIT_LOG_VERSION);
    config.defaultRetentionDays = readInt(envOr("AUDITLOG_DEFAULT_RETENTION_DAYS", "90"), 90);
    config.defaultPlan = envOr("AUDITLOG_DEFAULT_PLAN", "default");
    config.premiumCostPerThousandEvents = readDouble(envOr("AUDITLOG_PREMIUM_COST_PER_1000", "0.75"), 0.75);

    auto mgmtToken = envOr("AUDITLOG_AUTH_TOKEN", "");
    if (mgmtToken.length > 0) {
        config.requireAuthToken = true;
        config.authToken = mgmtToken;
    }

    auto oauthToken = envOr("AUDITLOG_OAUTH_TOKEN", "");
    if (oauthToken.length > 0) {
        config.requireOAuthToken = true;
        config.oauthToken = oauthToken;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new AuditLogService(config);
    auto server = new AuditLogServer(service);

    writeln("Starting Audit Log service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
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
        auto parsed = to!int(value);
        return parsed > 0 ? parsed : fallback;
    } catch (Exception) {
        return fallback;
    }
}

private double readDouble(string value, double fallback) {
    try {
        auto parsed = to!double(value);
        return parsed > 0 ? parsed : fallback;
    } catch (Exception) {
        return fallback;
    }
}
