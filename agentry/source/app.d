/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.agentry;

version (unittest) {
} else {
void main() {
    AgentryConfig config = new AgentryConfig;
    config.host = envOr("AGENTRY_HOST", "0.0.0.0");
    config.port = readPort(envOr("AGENTRY_PORT", "8089"), 8089);
    config.basePath = envOr("AGENTRY_BASE_PATH", "/api/agentry");
    config.serviceName = envOr("AGENTRY_SERVICE_NAME", "uim-sap-agentry");
    config.serviceVersion = envOr("AGENTRY_SERVICE_VERSION", UIM_AGENTRY_VERSION);
    config.defaultBackendSystem = envOr("AGENTRY_DEFAULT_BACKEND", "s4-primary");

    auto token = envOr("AGENTRY_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new AgentryService(config);
    auto server = new AgentryServer(service);

    writeln("Starting Agentry service on ", config.host, ":", config.port);
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
