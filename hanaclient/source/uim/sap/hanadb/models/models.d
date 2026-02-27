/**
 * Data models for HANA DB client
 */
module uim.sap.hanadb.models.models;

import vibe.data.json : Json;
import std.datetime : SysTime;

struct HanaDBQueryRequest {
    string statement;
    Json parameters = Json.emptyArray;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["statement"] = Json(statement);
        payload["parameters"] = parameters;
        return payload;
    }
}

struct HanaDBResultSet {
    string[] columns;
    Json[] rows;
    long rowCount;
}

struct HDBResponse {
    bool success;
    int statusCode;
    string errorMessage;
    Json raw = Json.emptyObject;
    HanaDBResultSet resultSet;
    SysTime timestamp;

    bool isSuccess() const pure nothrow @safe @nogc {
        return success;
    }
}
