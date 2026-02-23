module uim.sap.jobs.models.cftaskrun;

import std.datetime : SysTime;

import vibe.data.json : Json;

struct CFTaskRun {
    string tenantId;
    string taskRunId;
    string taskName;
    int durationSeconds;
    string status;
    SysTime startedAt;
    SysTime finishedAt;

    Json toJson() const {
        Json data = Json.emptyObject;
        data["tenant_id"] = tenantId;
        data["task_run_id"] = taskRunId;
        data["task_name"] = taskName;
        data["duration_seconds"] = durationSeconds;
        data["status"] = status;
        data["started_at"] = startedAt.toISOExtString();
        data["finished_at"] = finishedAt.toISOExtString();
        return data;
    }
}
