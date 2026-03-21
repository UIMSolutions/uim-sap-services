module uim.sap.eventmesh.models.subscription;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

struct EVMSubscription {
    UUID tenantId;
    string subscriptionId;
    string topicName;
    string queueName;
    string deliveryMode = "push";
    bool active = true;
    string createdAt;
    string updatedAt;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["subscription_id"] = subscriptionId;
        j["topic_name"] = topicName;
        j["queue_name"] = queueName;
        j["delivery_mode"] = deliveryMode;
        j["active"] = active;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

EVMSubscription subscriptionFromJson(UUID tenantId, Json request) {
    EVMSubscription s;
    s.tenantId = UUID(tenantId);
    s.subscriptionId = randomUUID().toString();

    if ("topic_name" in request && request["topic_name"].isString) {
        s.topicName = request["topic_name"].get!string;
    }
    if ("queue_name" in request && request["queue_name"].isString) {
        s.queueName = request["queue_name"].get!string;
    }
    if ("delivery_mode" in request && request["delivery_mode"].isString) {
        s.deliveryMode = request["delivery_mode"].get!string;
    }

    s.createdAt = Clock.currTime().toISOExtString();
    s.updatedAt = s.createdAt;
    return s;
}
