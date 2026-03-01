/**
 * Models for S/4HANA client
 */
module uim.sap.s4hana.models.response;

import vibe.data.json : Json;
import std.datetime : SysTime;



struct S4HANAResponse {
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
