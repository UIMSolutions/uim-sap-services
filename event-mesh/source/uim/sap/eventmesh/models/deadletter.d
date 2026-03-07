module uim.sap.eventmesh.models.deadletter;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

struct EVMDeadLetter {
    string tenantId;
    string deadLetterId;
    string queueName;
    string messageId;
    string reason;
    long attemptCount;
    string failedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["dead_letter_id"] = deadLetterId;
        j["queue_name"] = queueName;
        j["message_id"] = messageId;
        j["reason"] = reason;
        j["attempt_count"] = attemptCount;
        j["failed_at"] = failedAt;
        return j;
    }
}
