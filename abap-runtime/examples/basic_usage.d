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
    ARTRuntimeConfig config = new ARTRuntimeConfig();
    config.host = "127.0.0.1";
    config.port = 8080;
    config.basePath = "/sap/abap/runtime";
    config.runtimeName = "uim-art";
    config.runtimeVersion = UIM_ART_VERSION;

    auto runtime = new ARTRuntime(config);

    runtime.registerProgram("Z_HELLO_WORLD", (request) {
        Json payload = Json.emptyObject
          .set("greeting", "Hello from ABAP Runtime")
          .set("user", request.user)
          .set("client", request.client);
        return successResult("Program executed", payload);
    });

    runtime.registerProgram("Z_ECHO", (request) {
        Json payload = Json.emptyObject
        payload["echo"] = request.parameters;
        return successResult("Echo completed", payload);
    });

    auto server = new ARTRuntimeServer(runtime);
    writeln("Starting ABAP Runtime on ", config.host, ":", config.port);
    server.run();
}
