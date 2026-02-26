/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.art.models.runtime.health;

import std.datetime : SysTime;

import vibe.data.json : Json;



struct ARTRuntimeHealth {
    bool ok;
    string runtimeName;
    string runtimeVersion;
    size_t registeredPrograms;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["ok"] = ok;
        payload["runtimeName"] = runtimeName;
        payload["runtimeVersion"] = runtimeVersion;
        payload["registeredPrograms"] = cast(long)registeredPrograms;
        return payload;
    }
}
