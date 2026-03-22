module uim.sap.eventmesh.models.topic;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

struct EVMTopic {
    UUID tenantId;
    string topicName;
    string description;
    long subscriberCount = 0;
    long messagesPublished = 0;
    string createdAt;
    string updatedAt;

    override Json toJson()  {
        return super.toJson()
        .set("tenant_id", tenantId)
        .set("topic_name", topicName)
        .set("description", description)
        .set("subscriber_count", subscriberCount)
        .set("messages_published", messagesPublished)
        .set("created_at", createdAt)
        .set("updated_at", updatedAt);
    }
}

EVMTopic topicFromJson(UUID tenantId, Json request) {
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
