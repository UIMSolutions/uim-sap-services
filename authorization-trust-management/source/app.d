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

