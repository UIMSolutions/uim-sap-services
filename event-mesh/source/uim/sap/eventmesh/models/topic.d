module uim.sap.eventmesh.models.topic;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

struct EVMTopic {
    string tenantId;
    string topicName;
    string description;
    long subscriberCount = 0;
    long messagesPublished = 0;
    string createdAt;
    string updatedAt;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["topic_name"] = topicName;
        j["description"] = description;
        j["subscriber_count"] = subscriberCount;
        j["messages_published"] = messagesPublished;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

EVMTopic topicFromJson(string tenantId, Json request) {
    EVMTopic t;
    t.tenantId = UUID(tenantId);

    if ("topic_name" in request && request["topic_name"].isString) {
        t.topicName = request["topic_name"].get!string;
    }
    if ("description" in request && request["description"].isString) {
        t.description = request["description"].get!string;
    }

    t.createdAt = Clock.currTime().toISOExtString();
    t.updatedAt = t.createdAt;
    return t;
}
