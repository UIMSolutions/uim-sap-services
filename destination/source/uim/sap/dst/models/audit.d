/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.dst.models.audit;

import uim.sap.dst;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// DSTAuditLog – audit trail for destination operations
// ---------------------------------------------------------------------------
struct DSTAuditLog {
    string tenantId;
    string logId;
    string destinationName;
    string action;     // "created", "updated", "deleted", "lookup", "cert-uploaded", …
    string message;
    string level;      // "info" | "warning" | "error"
    SysTime timestamp;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"]        = tenantId;
        j["log_id"]           = logId;
        j["destination_name"] = destinationName;
        j["action"]           = action;
        j["message"]          = message;
        j["level"]            = level;
        j["timestamp"]        = timestamp.toISOExtString();
        return j;
    }
}
