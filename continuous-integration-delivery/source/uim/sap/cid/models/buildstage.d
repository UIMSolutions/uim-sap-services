module uim.sap.cid.models.buildstage;

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