module uim.sap.eventmesh.models.queue;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

struct EVMQueue {
  UUID tenantId;
  string queueName;
  long maxDepth = 1000;
  long messageCount = 0;
  long deadLetterCount = 0;
  bool enableDeadLetterQueue = true;
  long maxRetries = 3;
  string status = "active";
  string createdAt;
  string updatedAt;

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("queue_name", queueName)
      .set("max_depth", maxDepth)
      .set("message_count", messageCount)
      .set("dead_letter_count", deadLetterCount)
      .set("enable_dead_letter_queue", enableDeadLetterQueue)
      .set("max_retries", maxRetries)
      .set("status", status)
      .set("created_at", createdAt)
      .set("updated_at", updatedAt);
  }
}

EVMQueue queueFromJson(UUID tenantId, Json request) {
  EVMQueue q;
  q.tenantId = UUID(tenantId);

  if ("queue_name" in request && request["queue_name"].isString) {
    q.queueName = request["queue_name"].get!string;
  }
  if ("max_depth" in request && request["max_depth"].isInteger) {
    q.maxDepth = request["max_depth"].get!long;
  }
  if ("enable_dead_letter_queue" in request) {
    if (request["enable_dead_letter_queue"].isBoolean) {
      q.enableDeadLetterQueue = request["enable_dead_letter_queue"].get!bool;
    }
  }
  if ("max_retries" in request && request["max_retries"].isInteger) {
    q.maxRetries = request["max_retries"].get!long;
  }

  q.createdAt = Clock.currTime().toISOExtString();
  q.updatedAt = q.createdAt;
  return q;
}
