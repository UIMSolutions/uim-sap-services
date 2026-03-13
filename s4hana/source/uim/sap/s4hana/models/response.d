/**
 * Models for S/4HANA client
 */
module uim.sap.s4hana.models.response;

import uim.sap.s4hana;

mixin(ShowModule!());

@safe:
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
