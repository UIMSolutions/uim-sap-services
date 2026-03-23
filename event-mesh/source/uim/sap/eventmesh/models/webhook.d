module uim.sap.eventmesh.models.webhook;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EVMWebhook : SAPTenantObject {
  mixin(SAPObjectTemplate!EVMWebhook);

  UUID webhookId;
  string queueName;
  string callbackUrl;
  string method = "POST";
  bool active = true;
  long deliveredCount = 0;
  long failedCount = 0;

  override Json toJson() {
    return super.toJson()
      .set("webhook_id", webhookId)
      .set("queue_name", queueName)
      .set("callback_url", callbackUrl)
      .set("method", method)
      .set("active", active)
      .set("delivered_count", deliveredCount)
      .set("failed_count", failedCount);
  }

  static EVMWebhook webhookFromJson(UUID tenantId, Json request) {
    EVMWebhook w = new EVMWebhook(request);
    w.tenantId = tenantId;
    w.webhookId = randomUUID().toString();

    if ("queue_name" in request && request["queue_name"].isString) {
      w.queueName = request["queue_name"].get!string;
    }
    if ("callback_url" in request && request["callback_url"].isString) {
      w.callbackUrl = request["callback_url"].get!string;
    }
    if ("method" in request && request["method"].isString) {
      w.method = request["method"].get!string;
    }

    w.createdAt = Clock.currTime().toISOExtString();
    w.updatedAt = w.createdAt;
    return w;
  }
}
