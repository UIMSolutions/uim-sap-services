/**
 * Models for Cloud Integration (CPI) client
 */
module uim.sap.cpi.models.response;

import vibe.data.json : Json;
import std.datetime : SysTime;


import uim.sap.cpi;

mixin(ShowModule!());

@safe:


struct CPIResponse {
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
