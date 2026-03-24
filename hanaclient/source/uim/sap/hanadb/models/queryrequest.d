/**
 * Data models for HANA DB client
 */
module uim.sap.hanadb.models.queryrequest;

import vibe.data.json : Json;
import std.datetime : SysTime;

struct HanaDBQueryRequest {
    string statement;
    Json parameters = Json.emptyArray;

    override Json toJson()  {
      return super.toJson()
        .set("statement", Json(statement))
        .set("parameters", parameters);
    }
}




