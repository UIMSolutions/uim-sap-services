/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.jobs.models.schedule;

import uim.sap.jobs;

mixin(ShowModule!());

@safe:

class Schedule : SAPTenantEntity {
  mixin(SAPTenantEntity!Schedule);

  UUID scheduleId;
  UUID jobId;
  string format;
  string humanExpression;
  string repeatAt;
  int repeatIntervalSeconds;
  string cron;
  string timezone;
  bool active;
  SysTime nextRunAt;
  SysTime updatedAt;

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("schedule_id", scheduleId)
      .set("job_id", jobId)
      .set("format", format)
      .set("human_expression", humanExpression)
      .set("repeat_at", repeatAt)
      .set("repeat_interval_seconds", repeatIntervalSeconds)
      .set("cron", cron)
      .set("timezone", timezone)
      .set("active", active)
      .set("next_run_at", nextRunAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }
}
