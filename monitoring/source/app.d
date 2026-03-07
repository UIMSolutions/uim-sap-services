/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.sap.mon;

mixin(ShowModule!());

@safe:

/*

   server.run();
} */ 

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

void main() {
    MONConfig config;
    config.host = envOr("MON_HOST", "0.0.0.0");
    config.port = readPort(envOr("MON_PORT", "8090"), 8090);
    config.basePath = envOr("MON_BASE_PATH", "/api/mon");
    config.serviceName = envOr("MON_SERVICE_NAME", "uim-sap-mon");
    config.serviceVersion = envOr("MON_SERVICE_VERSION", UIM_MON_VERSION);

    auto service = new MONService(config);
    auto server = new MONServer(service);

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["0.0.0.0"];
    
    auto token = envOr("MON_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    logInfo("Starting MON service on ", config.host, ":", config.port);
    logInfo("Base path: ", config.basePath);

    auto router = new URLRouter;
    listenHTTP(settings, router);
    
    runApplication();
}
