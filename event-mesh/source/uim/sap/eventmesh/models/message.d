module uim.sap.eventmesh.models.message;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

struct EVMMessage {
    UUID tenantId;
    string messageId;
    string topicName;
    string queueName;
    string publisher;
    string source;
    Json payload = Json.emptyObject;
    string status = "pending";
    long retryCount = 0;
    string publishedAt;
    string consumedAt;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["message_id"] = messageId;
        j["topic_name"] = topicName;
        j["queue_name"] = queueName;
        j["publisher"] = publisher;
        j["source"] = source;
        j["payload"] = payload;
        j["status"] = status;
        j["retry_count"] = retryCount;
        j["published_at"] = publishedAt;
        j["consumed_at"] = consumedAt;
        return j;
    }
}

EVMMessage messageFromJson(UUID tenantId, string topicName, Json request) {
    EVMMessage m;
    m.tenantId = UUID(tenantId);
    m.messageId = randomUUID().toString();
    m.topicName = topicName;

    if ("publisher" in request && request["publisher"].isString) {
        m.publisher = request["publisher"].get!string;
    }
    if ("source" in request && request["source"].isString) {
        m.source = request["source"].get!string;
    }
    if ("payload" in request) {
        m.payload = request["payload"];
    } else {
        m.payload = Json.emptyObject;
    }

    m.publishedAt = Clock.currTime().toISOExtString();
    return m;
}
