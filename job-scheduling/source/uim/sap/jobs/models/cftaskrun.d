/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.jobs.models.cftaskrun;

import uim.sap.jobs;

mixin(ShowModule!());

@safe:

class CFTaskRun : SAPTenantEntity {
  mixin(SAPTenantEntity!CFTaskRun);

  UUID taskRunId;
  string taskName;
  int durationSeconds;
  string status;
  SysTime startedAt;
  SysTime finishedAt;

  override Json toJson() {
    return super.toJson()
      .set("task_run_id", taskRunId)
      .set("task_name", taskName)
      .set("duration_seconds", durationSeconds)
      .set("status", status)
      .set("started_at", startedAt.toISOExtString())
      .set("finished_at", finishedAt.toISOExtString());
  }
}
