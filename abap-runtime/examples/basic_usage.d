/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module art.examples.basic_usage;

import std.stdio : writeln;

import vibe.data.json : Json;

import uim.sap.art;

void main() {
    ARTRuntimeConfig config;
    config.host = "127.0.0.1";
    config.port = 8080;
    config.basePath = "/sap/abap/runtime";
    config.runtimeName = "uim-art";
    config.runtimeVersion = UIM_SAP_ART_VERSION;

    auto runtime = new ARTRuntime(config);

    runtime.registerProgram("Z_HELLO_WORLD", (request) {
        Json payload = Json.emptyObject;
        payload["greeting"] = "Hello from ABAP Runtime";
        payload["user"] = request.user;
        payload["client"] = request.client;
        return successResult("Program executed", payload);
    });

    runtime.registerProgram("Z_ECHO", (request) {
        Json payload = Json.emptyObject;
        payload["echo"] = request.parameters;
        return successResult("Echo completed", payload);
    });

    auto server = new ARTRuntimeServer(runtime);
    writeln("Starting SAP ABAP Runtime on ", config.host, ":", config.port);
    server.run();
}
