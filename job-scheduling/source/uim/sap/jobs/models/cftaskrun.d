/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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

    override Json toJson()  {
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
