module uim.sap.eventmesh.models.webhook;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

struct EVMWebhook {
    string tenantId;
    string webhookId;
    string queueName;
    string callbackUrl;
    string method = "POST";
    bool active = true;
    long deliveredCount = 0;
    long failedCount = 0;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["webhook_id"] = webhookId;
        j["queue_name"] = queueName;
        j["callback_url"] = callbackUrl;
        j["method"] = method;
        j["active"] = active;
        j["delivered_count"] = deliveredCount;
        j["failed_count"] = failedCount;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

EVMWebhook webhookFromJson(string tenantId, Json request) {
    EVMWebhook w;
    w.tenantId = tenantId;
    w.webhookId = randomUUID().toString();

    if ("queue_name" in request && request["queue_name"].isString) {
        w.queueName = request["queue_name"].get!string;
    }
    if ("callback_url" in request && request["callback_url"].isString) {
        w.callbackUrl = request["callback_url"].get!string;
    }
    if ("method" in request && request["method"].isString) {
        w.method = request["method"].get!string;
    }

    w.createdAt = Clock.currTime().toISOExtString();
    w.updatedAt = w.createdAt;
    return w;
}
