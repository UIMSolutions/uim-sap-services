module uim.sap.eventmesh.models.queue;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

struct EMQueue {
    string tenantId;
    string queueName;
    long maxDepth = 1000;
    long messageCount = 0;
    long deadLetterCount = 0;
    bool enableDeadLetterQueue = true;
    long maxRetries = 3;
    string status = "active";
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["queue_name"] = queueName;
        j["max_depth"] = maxDepth;
        j["message_count"] = messageCount;
        j["dead_letter_count"] = deadLetterCount;
        j["enable_dead_letter_queue"] = enableDeadLetterQueue;
        j["max_retries"] = maxRetries;
        j["status"] = status;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

EMQueue queueFromJson(string tenantId, Json request) {
    EMQueue q;
    q.tenantId = tenantId;

    if ("queue_name" in request && request["queue_name"].isString) {
        q.queueName = request["queue_name"].get!string;
    }
    if ("max_depth" in request && request["max_depth"].type == Json.Type.int_) {
        q.maxDepth = request["max_depth"].get!long;
    }
    if ("enable_dead_letter_queue" in request) {
        if (request["enable_dead_letter_queue"].type == Json.Type.bool_) {
            q.enableDeadLetterQueue = request["enable_dead_letter_queue"].get!bool;
        }
    }
    if ("max_retries" in request && request["max_retries"].type == Json.Type.int_) {
        q.maxRetries = request["max_retries"].get!long;
    }

    q.createdAt = Clock.currTime().toISOExtString();
    q.updatedAt = q.createdAt;
    return q;
}
