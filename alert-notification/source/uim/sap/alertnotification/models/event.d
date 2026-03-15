module uim.sap.alertnotification.models.event;

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
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["alert_id"] = alertId;
    result["event_type"] = eventType;
    result["category"] = category;
    result["severity"] = severity;
    result["source"] = source;
    result["subject"] = subject;
    result["message"] = message;
    result["tags"] = tags;
    result["payload"] = payload;
    result["created_at"] = createdAt.toISOExtString();
    return result;
  }
}