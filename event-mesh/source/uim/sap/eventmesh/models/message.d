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

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("message_id", messageId)
      .set("topic_name", topicName)
      .set("queue_name", queueName)
      .set("publisher", publisher)
      .set("source", source)
      .set("payload", payload)
      .set("status", status)
      .set("retry_count", retryCount)
      .set("published_at", publishedAt)
      .set("consumed_at", consumedAt);
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
