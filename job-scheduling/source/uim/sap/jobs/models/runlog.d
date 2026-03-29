/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.jobs.models.runlog;

import uim.sap.jobs;

mixin(ShowModule!());

@safe:

class RunLog : SAPTenantEntity {
  mixin(SAPTenantEntity!RunLog);

  UUID runId;
  UUID jobId;
  UUID scheduleId;
  string runtime;
  bool asyncRun;
  string status;
  int responseCode;
  string message;
  SysTime startedAt;
  SysTime finishedAt;

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("run_id", runId)
      .set("job_id", jobId)
      .set("schedule_id", scheduleId)
      .set("runtime", runtime)
      .set("async_run", asyncRun)
      .set("status", status)
      .set("response_code", responseCode)
      .set("message", message)
      .set("started_at", startedAt.toISOExtString())
      .set("finished_at", finishedAt.toISOExtString());
  }
}
