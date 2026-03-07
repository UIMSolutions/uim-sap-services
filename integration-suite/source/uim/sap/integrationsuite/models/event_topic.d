/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.event_topic;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct ISEventTopic {
    string tenantId;
    string topicId;
    string topicName;
    string description;
    long subscriberCount = 0;
    long messagesPublished = 0;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["topic_id"] = topicId;
        j["topic_name"] = topicName;
        j["description"] = description;
        j["subscriber_count"] = subscriberCount;
        j["messages_published"] = messagesPublished;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

ISEventTopic eventTopicFromJson(string tenantId, Json request) {
    ISEventTopic t;
    t.tenantId = tenantId;
    t.topicId = randomUUID().toString();

    if ("topic_name" in request && request["topic_name"].isString)
        t.topicName = request["topic_name"].get!string;
    if ("description" in request && request["description"].isString)
        t.description = request["description"].get!string;

    t.createdAt = Clock.currTime().toISOExtString();
    t.updatedAt = t.createdAt;
    return t;
}
