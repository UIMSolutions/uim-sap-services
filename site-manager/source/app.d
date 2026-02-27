/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.smg;

void main() {
    SMGConfig config;
    config.host = envOr("SMG_HOST", "0.0.0.0");
    config.port = readPort(envOr("SMG_PORT", "8094"), 8094);
    config.basePath = envOr("SMG_BASE_PATH", "/api/sitemanager");
    config.serviceName = envOr("SMG_SERVICE_NAME", "uim-sap-smg");
    config.serviceVersion = envOr("SMG_SERVICE_VERSION", UIM_SMG_VERSION);

    auto token = envOr("SMG_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new SMGService(config);
    auto server = new SMGServer(service);

    writeln("Starting Site Manager service on ", config.host, ":", config.port);
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
