/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.jobs.models.job;

import uim.sap.jobs;

mixin(ShowModule!());

@safe:

class Job : SAPTenantEntity {
  mixin(SAPTenantEntity!Job);

    UUID jobId;
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

    override Json toJson()  {
      return super.toJson()
        .set("job_id", jobId)
        .set("name", name)
        .set("description", description)
        .set("action_endpoint", actionEndpoint)
        .set("http_method", httpMethod)
        .set("payload", payload)
        .set("runtime", runtime)
        .set("execution_mode", executionMode)
        .set("long_running_task", longRunningTask)
        .set("active", active);
    }
}
