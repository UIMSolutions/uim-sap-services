/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import vibe.core.core : runApplication;
import uim.sap.aem;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
void main() {
    AEMConfig config = new AEMConfig;
    config.host = envOr("AEM_HOST", "0.0.0.0");
    config.port = readPort(envOr("AEM_PORT", "8088"), 8088);
    config.basePath = envOr("AEM_BASE_PATH", "/api/aem");
    config.serviceName = envOr("AEM_SERVICE_NAME", "uim-aem");
    config.serviceVersion = envOr("AEM_SERVICE_VERSION", UIM_AEM_VERSION);
    config.defaultMeshRegion = envOr("AEM_DEFAULT_REGION", "eu10");

    auto token = envOr("AEM_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken(true);
        config.authToken(token);
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new AEMService(config);
    auto server = new AEMServer(service);

    writeln("Starting AEM service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
}}

