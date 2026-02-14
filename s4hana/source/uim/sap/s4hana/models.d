/**
 * Models for SAP S/4HANA client
 */
module uim.sap.s4hana.models;

import vibe.data.json : Json;
import std.datetime : SysTime;

struct SAPS4HANARequest {
    string servicePath;
    string entityPath;
    string[string] query;
    Json payload = Json.emptyObject;

    string requestPath() const {
        auto service = servicePath;
        if (service.length > 0 && service[$ - 1] == '/') {
            service = service[0 .. $ - 1];
        }

        auto entity = entityPath;
        if (entity.length > 0 && entity[0] == '/') {
            entity = entity[1 .. $];
        }

        if (entity.length == 0) {
            return service;
        }

        return service ~ "/" ~ entity;
    }
}

struct SAPS4HANAResponse {
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
