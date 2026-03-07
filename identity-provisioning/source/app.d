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
import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
void main() {
    IPVConfig config = new IPVConfig;
    config.host = envOr("IPV_HOST", "0.0.0.0");
    config.port = readPort(envOr("IPV_PORT", "8095"), 8095);
    config.basePath = envOr("IPV_BASE_PATH", "/api/ip");
    config.serviceName = envOr("IPV_SERVICE_NAME", "uim-sap-ip");
    config.serviceVersion = envOr("IPV_SERVICE_VERSION", UIM_IPV_VERSION);

    auto token = envOr("IPV_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new IPVService(config);
    auto server = new IPVServer(service);

    writeln("Starting Identity Provisioning service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
}}

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
