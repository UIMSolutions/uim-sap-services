/**
 * Data models for HANA DB client
 */
module uim.sap.hanadb.models.queryrequest;

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




