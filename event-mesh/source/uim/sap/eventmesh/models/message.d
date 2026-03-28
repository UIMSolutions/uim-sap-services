module uim.sap.eventmesh.models.message;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EVMMessage : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!EVMMessage);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("message_id" in initData && initData["message_id"].isString) {
      messageId = UUID(initData["message_id"].get!string);
    } else {
      messageId = randomUUID();
    }
    topicName = initData.getString("topic_name", "");
    queueName = initData.getString("queue_name", "");
    status = initData.getString("status", "pending");
    retryCount = initData.getLong("retry_count", 0);
    consumedAt = initData.getString("consumed_at", "");

    publisher = initData.getString("publisher", "");
    source = initData.getString("source", "");
    payload = initData.get("payload", Json.emptyObject);
    publishedAt = initData.getString("published_at", Clock.currTime().toISOExtString());

    return true;
  }

  UUID messageId;
  string topicName;
  string queueName;
  string publisher;
  string source;
  Json payload;
  string status;
  long retryCount;
  string publishedAt;
  string consumedAt;

  override Json toJson() {
    return super.toJson()
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

  static EVMMessage messageFromJson(UUID tenantId, string topicName, Json request) {
    EVMMessage message = new EVMMessage(request);
    message.tenantId = tenantId;
    message.topicName = topicName;

    return message;
  }
}
