module uim.sap.atp.models.eventtrigger;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

class ATPEventTrigger : SAPTenantObject {
  mixin(SAPObjectTemplate!ATPEventTrigger);

  string triggerId;
  string eventSource;
  string eventType;
  string commandId;
  bool active;

  override Json toJson() {
    return super.toJson
      .set("trigger_id", triggerId)
      .set("event_source", eventSource)
      .set("event_type", eventType)
      .set("command_id", commandId)
      .set("active", active);
  }
}
