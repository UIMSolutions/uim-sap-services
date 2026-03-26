module uim.sap.eventmesh.models.deadletter;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EVMDeadLetter : SAPTenantObject {
  mixin(SAPObjectTemplate!EVMDeadLetter);
  
  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    queueName = initData.getString("queue_name", "");
    reason = initData.getString("reason", "");
    attemptCount = initData.getLong("attempt_count", 0);
    failedAt = initData.getString("failed_at", "");

    return true;
  }

  UUID deadLetterId;
  UUID messageId;
  string queueName;
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
