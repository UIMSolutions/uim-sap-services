/**
 * Data models for SAP HANA DB client
 */
module uim.sap.hanadb.models;

import vibe.data.json : Json;
import std.datetime : SysTime;

struct SAPHanaDBQueryRequest {
    string statement;
    Json parameters = Json.emptyArray;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["statement"] = Json(statement);
        payload["parameters"] = parameters;
        return payload;
    }
}

struct SAPHanaDBResultSet {
    string[] columns;
    Json[] rows;
    long rowCount;
}

struct SAPHanaDBResponse {
    bool success;
    int statusCode;
    string errorMessage;
    Json raw = Json.emptyObject;
    SAPHanaDBResultSet resultSet;
    SysTime timestamp;

    bool isSuccess() const pure nothrow @safe @nogc {
        return success;
    }
}
