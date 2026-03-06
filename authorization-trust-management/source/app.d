module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import vibe.core.core : runApplication;

import uim.sap.atm;

void main() {
    ATMConfig config = new ATMConfig;
    config.host = envOr("ATM_HOST", "0.0.0.0");
    config.port = readPort(envOr("ATM_PORT", "8088"), 8088);
    config.basePath = envOr("ATM_BASE_PATH", "/api/atm");
    config.serviceName = envOr("ATM_SERVICE_NAME", "uim-sap-atm");
    config.serviceVersion = envOr("ATM_SERVICE_VERSION", UIM_ATM_VERSION);
    config.defaultIdpName = envOr("ATM_DEFAULT_IDP_NAME", "sap-id-service");
    config.defaultIdpIssuer = envOr("ATM_DEFAULT_IDP_ISSUER", "https://accounts.sap.com");
    config.defaultIdpAudience = envOr("ATM_DEFAULT_IDP_AUDIENCE", "uim-sap-app");
    config.allowUnsignedTokens = readBool(envOr("ATM_ALLOW_UNSIGNED_TOKENS", "true"), true);
    config.enforceTokenExpiry = readBool(envOr("ATM_ENFORCE_TOKEN_EXPIRY", "true"), true);
    config.bootstrapToken = envOr("ATM_BOOTSTRAP_TOKEN", "");

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new ATMService(config);
    auto server = new ATMServer(service);

    writeln("Starting ATM service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
    runApplication();
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

private bool readBool(string value, bool fallback) {
    auto normalized = value.dup;
    foreach (index, c; normalized) {
        if (c >= 'A' && c <= 'Z') {
            normalized[index] = cast(char)(c + 32);
        }
    }

    if (normalized == "1" || normalized == "true" || normalized == "yes" || normalized == "y") {
        return true;
    }
    if (normalized == "0" || normalized == "false" || normalized == "no" || normalized == "n") {
        return false;
    }
    return fallback;
}
