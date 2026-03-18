module uim.sap.ctm.models.transportlog;

import uim.sap.ctm;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// CTMTransportLog – an audit/monitoring log entry
// ---------------------------------------------------------------------------
struct CTMTransportLog {
    string tenantId;
    string logId;
    string requestId;
    string nodeId;
    string action;     // e.g. "created", "forwarded", "queued", "import-started",
                       //      "import-success", "import-error", "reset", "scheduled"
    string message;
    /// Level: "info" | "warning" | "error"
    string level;
    SysTime timestamp;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"]  = tenantId;
        j["log_id"]     = logId;
        j["request_id"] = requestId;
        j["node_id"]    = nodeId;
        j["action"]     = action;
        j["message"]    = message;
        j["level"]      = level;
        j["timestamp"]  = timestamp.toISOExtString();
        return j;
    }
}
