module uim.sap.eventmesh.models.subscription;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EVMSubscription : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!EVMSubscription);

  UUID subscriptionId;
  string topicName;
  string queueName;
  string deliveryMode = "push";
  bool active = true;

  override Json toJson() {
    return super.toJson()
      .set("subscription_id", subscriptionId)
      .set("topic_name", topicName)
      .set("queue_name", queueName)
      .set("delivery_mode", deliveryMode)
      .set("active", active);
  }

  static EVMSubscription opCall(UUID tenantId, Json request) {
    EVMSubscription s = new EVMSubscription(request);
    s.tenantId = tenantId;
    s.subscriptionId = randomUUID();

    if ("topic_name" in request && request["topic_name"].isString) {
      s.topicName = request["topic_name"].getString;
    }
    if ("queue_name" in request && request["queue_name"].isString) {
      s.queueName = request["queue_name"].getString;
    }
    if ("delivery_mode" in request && request["delivery_mode"].isString) {
      s.deliveryMode = request["delivery_mode"].getString;
    }

    s.createdAt = Clock.currTime();
    s.updatedAt = s.createdAt;
    return s;
  }

}
