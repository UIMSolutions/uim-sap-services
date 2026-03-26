module uim.sap.auditlog.models.event;
import uim.sap.auditlog;

mixin(ShowModule!());

@safe:

class AuditLogEvent : SAPTenantObject {
  mixin(SAPObjectTemplate!AuditLogEvent);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    eventId = initData.getString("event_id", "");
    eventType = toLower(initData.getString("event_type", ""));
    severity = toLower(initData.getString("severity", ""));
    category = toLower(initData.getString("category", ""));
    message = initData.getString("message", "");
    sourceService = initData.getString("source_service", "");
    actor = initData.getString("actor", "");
    
    if ("details" in initData && initData["details"].isObject) {
      details = initData["details"];
    }

    return true;
  }

  UUID eventId;
  string eventType;
  string severity;
  string category;
  string message;
  string sourceService;
  string actor;
  Json details;
  SysTime createdAt;

  override Json toJson() {
    return super.toJson()
      .set("event_id", eventId.toJson)
      .set("event_type", eventType)
      .set("severity", severity)
      .set("category", category)
      .set("message", message)
      .set("source_service", sourceService)
      .set("actor", actor)
      .set("details", details)
      .set("created_at", createdAt.toISOExtString())
      .set("recommended_type", isRecommendedAuditEventType(eventType));
  }

  AuditLogEvent eventFromJson(UUID tenantId, Json request) {
    AuditLogEvent eventItem = new AuditLogEvent(request);

    eventItem.tenantId = tenantId;
    eventItem.eventId = randomUUID();
    eventItem.eventType = "system_event";
    eventItem.severity = "info";
    eventItem.category = "audit";
    eventItem.sourceService = "unknown";
    eventItem.actor = "system";
    eventItem.details = Json.emptyObject;
    eventItem.createdAt = Clock.currTime();

    return eventItem;
  }

}
