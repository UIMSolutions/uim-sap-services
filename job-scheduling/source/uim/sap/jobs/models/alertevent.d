/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.jobs.models.alertevent;

import uim.sap.jobs;

mixin(ShowModule!());

@safe:

class AlertEvent : SAPTenantObject {
  mixin(SAPtenantObject!AlertEvent);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("alert_id" in request && request["alert_id"].isString) {
      alertId = UUID(request["alert_id"].get!string);
    }
    if ("event_type" in request && request["event_type"].isString) {
      eventType = request["event_type"].getString;
    }
    if ("job_id" in request && request["job_id"].isString) {
      jobId = UUID(request["job_id"].get!string);
    }
    if ("run_id" in request && request["run_id"].isString) {
      runId = UUID(request["run_id"].get!string);
    }
    if ("status" in request && request["status"].isString) {
      status = request["status"].getString;
    }
    if ("severity" in request && request["severity"].isString) {
      severity = request["severity"].getString;
    }
    if ("message" in request && request["message"].isString) {
      message = request["message"].getString;
    }

    return true;
  }

  UUID alertId;
  string eventType;
  UUID jobId;
  UUID runId;
  string status;
  string severity;
  string message;

  override Json toJson() {
    return super.toJson()
      .set("alert_id", alertId)
      .set("event_type", eventType)
      .set("job_id", jobId)
      .set("run_id", runId)
      .set("status", status)
      .set("severity", severity)
      .set("message", message);
  }
}
