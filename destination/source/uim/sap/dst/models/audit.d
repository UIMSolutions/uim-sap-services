module uim.sap.dst.models.audit;

import uim.sap.dst;

mixin(ShowModule!());

@safe:

string createId() {
    return randomUUID().toString();
}






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

    Json toJson() const {
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
