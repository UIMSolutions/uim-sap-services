module uim.sap.eventmesh.models.deadletter;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

struct EVMDeadLetter {
  UUID tenantId;
  UUID deadLetterId;
  string queueName;
  UUID messageId;
  string reason;
  long attemptCount;
  string failedAt;

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("dead_letter_id", deadLetterId)
      .set("queue_name", queueName)
      .set("message_id", messageId)
      .set("reason", reason)
      .set("attempt_count", attemptCount)
      .set("failed_at", failedAt);
  }
}
