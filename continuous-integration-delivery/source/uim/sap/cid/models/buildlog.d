module uim.sap.cid.models.buildlog;

import uim.sap.cid;

mixin(ShowModule!());

@safe:


// ---------------------------------------------------------------------------
// CIDBuildLog – a log entry produced during a build
// ---------------------------------------------------------------------------
struct CIDBuildLog {
    string tenantId;
    string logId;
    string buildId;
    /// Optional: stage this log belongs to
    string stageId;
    /// Level: "info" | "warning" | "error" | "debug"
    string level;
    string message;
    SysTime timestamp;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["log_id"]    = logId;
        j["build_id"]  = buildId;
        j["stage_id"]  = stageId;
        j["level"]     = level;
        j["message"]   = message;
        j["timestamp"] = timestamp.toISOExtString();
        return j;
    }
}
