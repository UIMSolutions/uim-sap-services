module uim.sap.cid.models;

import uim.sap.cid;

mixin(ShowModule!());

@safe:






// ---------------------------------------------------------------------------
// CIDBuildStage – one stage within a build run
// ---------------------------------------------------------------------------
struct CIDBuildStage {
    string buildId;
    string stageId;
    /// Stage name: "build" | "test" | "deploy" | custom
    string name;
    /// Order within the build (1-based)
    int ordinal;
    /// Status: "pending" | "running" | "success" | "failure" | "skipped"
    string status;
    long durationSecs;
    SysTime startedAt;
    SysTime finishedAt;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["build_id"]      = buildId;
        j["stage_id"]      = stageId;
        j["name"]          = name;
        j["ordinal"]       = ordinal;
        j["status"]        = status;
        j["duration_secs"] = durationSecs;
        j["started_at"]    = startedAt.toISOExtString();
        j["finished_at"]   = finishedAt.toISOExtString();
        return j;
    }
}

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
