/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cis.models.joblog;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

/** 
  * Model representing a log entry for a job execution in the UIM Cloud Identity Services (CIS) module.
  * This struct is used to capture and store log information related to job executions, including the tenant ID, log ID, job ID, log level, message, and creation timestamp.
  * Fields:
  * - `tenantId`: The ID of the tenant this log entry belongs to.
  * - `logId`: The unique ID of the log entry.
  * - `jobId`: The ID of the job this log entry is associated with.
  * - `level`: The log level (e.g., "INFO", "WARN", "ERROR").
  * - `message`: The log message providing details about the job execution.
  * - `createdAt`: The timestamp of when the log entry was created.
  * Methods:
  * - `toJson()`: Converts the job log entry to a JSON object for API responses or storage.
  * Example usage:
  * ```
  * CISJobLog logEntry;
  * logEntry.tenantId = "tenant123";
  * logEntry.logId = "log456";
  * logEntry.jobId = "job789";
  * logEntry.level = "INFO";
  * logEntry.message = "Job executed successfully";   
  * logEntry.createdAt = Clock.currTime();
  * Json logJson = logEntry.toJson();
  * ```
  * Note: The `toJson()` method is used to serialize the job log entry into a JSON format that can be returned in API responses or stored in a database. The actual implementation of the `to
 */
class CISJobLog : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!CISJobLog);

  UUID logId;
  UUID jobId;
  string level;
  string message;

  override Json toJson() {
    return super.toJson
      .set("log_id", logId)
      .set("job_id", jobId)
      .set("level", level)
      .set("message", message);
  }
}
