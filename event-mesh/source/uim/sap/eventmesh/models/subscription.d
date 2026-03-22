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

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("subscription_id", subscriptionId)
      .set("topic_name", topicName)
      .set("queue_name", queueName)
      .set("delivery_mode", deliveryMode)
      .set("active", active)
      .set("created_at", createdAt)
      .set("updated_at", updatedAt);
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
