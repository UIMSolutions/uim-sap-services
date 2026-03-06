module uim.sap.tkc.models.taskaction;

import std.datetime : SysTime;

import vibe.data.json : Json;

@safe:

struct TCTaskAction {
    string action;
    string performedBy;
    string comment;
    SysTime performedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["action"] = action;
        payload["performed_by"] = performedBy;
        payload["comment"] = comment;
        payload["performed_at"] = performedAt.toISOExtString();
        return payload;
    }
}
