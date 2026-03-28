module uim.sap.eventmesh.models.topic;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EVMTopic : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!EVMTopic);

  string topicName;
  string description;
  long subscriberCount = 0;
  long messagesPublished = 0;

  override Json toJson() {
    return super.toJson()
      .set("topic_name", topicName)
      .set("description", description)
      .set("subscriber_count", subscriberCount)
      .set("messages_published", messagesPublished);
  }
}

EVMTopic topicFromJson(UUID tenantId, Json request) {
  EVMTopic t = new EVMTopic(request);
  t.tenantId = tenantId;

  if ("topic_name" in request && request["topic_name"].isString) {
    t.topicName = request["topic_name"].getString;
  }
  if ("description" in request && request["description"].isString) {
    t.description = request["description"].getString;
  }

  t.createdAt = Clock.currTime();
  t.updatedAt = t.createdAt;
  return t;
}
