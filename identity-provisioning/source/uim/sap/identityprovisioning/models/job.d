module uim.sap.identityprovisioning.models.job;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

/** A provisioning job that reads entities from a source system and
 *  writes them to one or more target systems.
 *
 *  `readMode` values: "full", "delta"
 *  `status` values: "pending", "running", "completed", "failed", "cancelled"
 */
struct IPVJob {
    string tenantId;
    string jobId;
    string jobName;
    string sourceSystemId;
    string[] targetSystemIds;
    string readMode = "full";       // "full" | "delta"
    string status = "pending";      // "pending" | "running" | "completed" | "failed" | "cancelled"
    long usersRead = 0;
    long usersWritten = 0;
    long usersSkipped = 0;
    long usersFailed = 0;
    long groupsRead = 0;
    long groupsWritten = 0;
    long groupsSkipped = 0;
    long groupsFailed = 0;
    string deltaToken;              // opaque token for delta read mode
    string startedAt;
    string completedAt;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["job_id"] = jobId;
        j["job_name"] = jobName;
        j["source_system_id"] = sourceSystemId;

        Json targets = Json.emptyArray;
        foreach (tid; targetSystemIds) {
            targets ~= Json(tid);
        }
        j["target_system_ids"] = targets;

        j["read_mode"] = readMode;
        j["status"] = status;
        j["users_read"] = usersRead;
        j["users_written"] = usersWritten;
        j["users_skipped"] = usersSkipped;
        j["users_failed"] = usersFailed;
        j["groups_read"] = groupsRead;
        j["groups_written"] = groupsWritten;
        j["groups_skipped"] = groupsSkipped;
        j["groups_failed"] = groupsFailed;
        j["delta_token"] = deltaToken;
        j["started_at"] = startedAt;
        j["completed_at"] = completedAt;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

IPVJob jobFromJson(string tenantId, Json request) {
    IPVJob j;
    j.tenantId = tenantId;
    j.jobId = randomUUID().toString();

    if ("job_name" in request && request["job_name"].isString)
        j.jobName = request["job_name"].get!string;
    if ("source_system_id" in request && request["source_system_id"].isString)
        j.sourceSystemId = request["source_system_id"].get!string;
    if ("read_mode" in request && request["read_mode"].isString)
        j.readMode = request["read_mode"].get!string;
    if ("delta_token" in request && request["delta_token"].isString)
        j.deltaToken = request["delta_token"].get!string;
    if ("job_id" in request && request["job_id"].isString)
        j.jobId = request["job_id"].get!string;

    if ("target_system_ids" in request && request["target_system_ids"].type == Json.Type.array) {
        () @trusted {
            foreach (item; request["target_system_ids"]) {
                if (item.isString)
                    j.targetSystemIds ~= item.get!string;
            }
        }();
    }

    j.createdAt = Clock.currTime().toISOExtString();
    j.updatedAt = j.createdAt;
    return j;
}
