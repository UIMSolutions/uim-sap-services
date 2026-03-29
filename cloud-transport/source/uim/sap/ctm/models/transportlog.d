module uim.sap.ctm.models.transportlog;

import uim.sap.ctm;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// CTMTransportLog – an audit/monitoring log entry
// ---------------------------------------------------------------------------
class CTMTransportLog : SAPTenantEntity {
    mixin(SAPEntityTemplate!CTMTransportLog);

    UUID logId;
    UUID requestId;
    UUID nodeId;
    string action;     // e.g. "created", "forwarded", "queued", "import-started",
                       //      "import-success", "import-error", "reset", "scheduled"
    string message;
    /// Level: "info" | "warning" | "error"
    string level;
    SysTime timestamp;

    override Json toJson()  {
        Json j = super.toJson;
        .set("log_id", logId)
        .set("request_id", requestId)
        .set("node_id", nodeId)
        .set("action", action)
        .set("message", message)
        .set("level", level)
        .set("timestamp", timestamp.toISOExtString());
    }
}
