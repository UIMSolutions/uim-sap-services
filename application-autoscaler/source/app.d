module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.aas;

void main() {
    AASConfig config = new AASConfig;
    config.host = envOr("AAS_HOST", "0.0.0.0");
    config.port = readPort(envOr("AAS_PORT", "8086"), 8086);
    config.basePath = envOr("AAS_BASE_PATH", "/api/autoscaler");
    config.serviceName = envOr("AAS_SERVICE_NAME", "uim-aas");
    config.serviceVersion = envOr("AAS_SERVICE_VERSION", UIM_AAS_VERSION);

    config.cfApi = envOr("AAS_CF_API", "");
    config.cfOrganization = envOr("AAS_CF_ORG", "");
    config.cfSpace = envOr("AAS_CF_SPACE", "");

    auto token = envOr("AAS_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken(true);
        config.authToken(token);
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new AASService(config);
    auto server = new AASServer(service);

    writeln("Starting AAS service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
}


