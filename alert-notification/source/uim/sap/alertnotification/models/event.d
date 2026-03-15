module uim.sap.alertnotification.models.event;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:
class AlertEvent : SAPTenantObject {
  mixin(SAPObjectTemplate!AlertEvent);

  UUID alertId;
  string eventType;
  string category;
  string severity;
  string source;
  string subject;
  string message;
  Json tags;
  Json payload = Json.emptyObject;

  override Json toJson()  {
    Json result = super.toJson();

    result["alert_id"] = alertId.toJson();
    result["event_type"] = eventType.toJson();
    result["category"] = category.toJson();
    result["severity"] = severity.toJson();
    result["source"] = source.toJson();
    result["subject"] = subject.toJson();
    result["message"] = message.toJson();
    result["tags"] = tags.toJson();
    result["payload"] = payload.toJson();

    return result;
  }
}