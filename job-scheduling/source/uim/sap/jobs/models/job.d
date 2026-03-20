/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.jobs.models.job;

import uim.sap.jobs;

mixin(ShowModule!());

@safe:

struct Job {
    UUID tenantId;
    string jobId;
    string name;
    string description;
    string actionEndpoint;
    string httpMethod;
    Json payload = Json.emptyObject;
    string runtime;
    string executionMode;
    bool longRunningTask;
    string oauthToken;
    bool active;
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json data = Json.emptyObject;
        data["tenant_id"] = tenantId;
        data["job_id"] = jobId;
        data["name"] = name;
        data["description"] = description;
        data["action_endpoint"] = actionEndpoint;
        data["http_method"] = httpMethod;
        data["payload"] = payload;
        data["runtime"] = runtime;
        data["execution_mode"] = executionMode;
        data["long_running_task"] = longRunningTask;
        data["active"] = active;
        data["created_at"] = createdAt.toISOExtString();
        data["updated_at"] = updatedAt.toISOExtString();
        return data;
    }
}
