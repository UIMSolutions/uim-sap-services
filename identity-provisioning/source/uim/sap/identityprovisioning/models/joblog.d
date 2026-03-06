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
    string tenantId;
    string logId;
    string jobId;
    string level = "info";     // "info" | "warning" | "error"
    string entityType;         // "user" | "group" | "system" | "job"
    string entityId;           // affected entity identifier
    string message;
    string details;
    string timestamp;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["log_id"] = logId;
        j["job_id"] = jobId;
        j["level"] = level;
        j["entity_type"] = entityType;
        j["entity_id"] = entityId;
        j["message"] = message;
        j["details"] = details;
        j["timestamp"] = timestamp;
        return j;
    }
}

/** Factory helper to create a new log entry. */
IPVJobLog createJobLog(string tenantId, string jobId, string level, string entityType,
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
