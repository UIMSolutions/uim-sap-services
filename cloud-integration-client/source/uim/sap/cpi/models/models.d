/**
 * Models for SAP Cloud Integration (CPI) client
 */
module uim.sap.cpi.models;

import vibe.data.json : Json;
import std.datetime : SysTime;

struct SAPCPIRequest {
    string path;
    string[string] query;
    Json payload = Json.emptyObject;
}

struct SAPCPIResponse {
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
