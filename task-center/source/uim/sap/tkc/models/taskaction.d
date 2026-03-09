/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.tkc.models.taskaction;

import uim.sap.tkc;

mixin(ShowModule!());

@safe:

struct TKCTaskAction {
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
