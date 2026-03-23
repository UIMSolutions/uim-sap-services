module uim.sap.eventmesh.models.webhook;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

struct EVMWebhook {
    UUID tenantId;
    UUID webhookId;
    string queueName;
    string callbackUrl;
    string method = "POST";
    bool active = true;
    long deliveredCount = 0;
    long failedCount = 0;
    string createdAt;
    string updatedAt;

    override Json toJson()  {
      return super.toJson()
        .set("tenant_id", tenantId)
        .set("webhook_id", webhookId)
        .set("queue_name", queueName)
        .set("callback_url", callbackUrl)
        .set("method", method)
        .set("active", active)
        .set("delivered_count", deliveredCount)
        .set("failed_count", failedCount)
        .set("created_at", createdAt)
        .set("updated_at", updatedAt);
    }
}

EVMWebhook webhookFromJson(UUID tenantId, Json request) {
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
