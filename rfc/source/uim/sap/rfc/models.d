/**
 * Models for RFC adapter
 *
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.rfc.models;

import vibe.data.json : Json;
import std.datetime : SysTime;

struct SAPRFCRequest {
    string functionName;
    Json parameters = Json.emptyObject;
    string destination;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["function"] = Json(functionName);
        payload["parameters"] = parameters;

        if (destination.length > 0) {
            payload["destination"] = Json(destination);
        }

        return payload;
    }
}

struct SAPRFCResponse {
    bool success;
    int statusCode;
    Json data = Json.emptyObject;
    string errorMessage;
    string[string] headers;
    SysTime timestamp;

    bool isSuccess() const pure nothrow @safe @nogc {
        return success;
    }
}
