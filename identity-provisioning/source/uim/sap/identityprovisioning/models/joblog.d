/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.identityprovisioning.models.joblog;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

/** A single log entry produced during a provisioning job.
 *
 *  `level` values: "info", "warning", "error"
 *  `entityType` values: "user", "group", "system", "job"
 */
struct IPVJobLog {
  UUID tenantId;
  UUID logId;
  UUID jobId;
  string level = "info"; // "info" | "warning" | "error"
  string entityType; // "user" | "group" | "system" | "job"
  UUID entityId; // affected entity identifier
  string message;
  string details;
  string timestamp;

  override Json toJson()  {
    return super.toJson()
    .set("tenant_id", tenantId)
    .set("log_id", logId)
    .set("job_id", jobId)
    .set("level", level)
    .set("entity_type", entityType)
    .set("entity_id", entityId)
    .set("message", message)
    .set("details", details)
    .set("timestamp", timestamp);
  }
}

/** Factory helper to create a new log entry. */
IPVJobLog createJobLog(UUID tenantId, string jobId, string level, string entityType,
  string entityId, string message, string details = "") {
  IPVJobLog log;
  log.tenantId = tenantId;
  log.logId = randomUUID().toString();
  log.jobId = jobId;
  log.level = level;
  log.entityType = entityType;
  log.entityId = entityId;
  log.message = message;
  log.details = details;
  log.timestamp = Clock.currTime().toISOExtString();
  return log;
}
