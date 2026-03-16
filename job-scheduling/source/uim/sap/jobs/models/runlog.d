/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.jobs.models.runlog;

import uim.sap.jobs;

mixin(ShowModule!());

@safe:

struct RunLog {
    string tenantId;
    string runId;
    string jobId;
    string scheduleId;
    string runtime;
    bool asyncRun;
    string status;
    int responseCode;
    string message;
    SysTime startedAt;
    SysTime finishedAt;

    override Json toJson()  {
        Json data = Json.emptyObject;
        data["tenant_id"] = tenantId;
        data["run_id"] = runId;
        data["job_id"] = jobId;
        data["schedule_id"] = scheduleId;
        data["runtime"] = runtime;
        data["async_run"] = asyncRun;
        data["status"] = status;
        data["response_code"] = responseCode;
        data["message"] = message;
        data["started_at"] = startedAt.toISOExtString();
        data["finished_at"] = finishedAt.toISOExtString();
        return data;
    }
}
