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

    if ("event_id" in initData && initData["event_id"].isString) {
      eventId = initData["event_id"].get!string;
    }
    if ("event_type" in initData && initData["event_type"].isString) {
      eventType = toLower(initData["event_type"].get!string);
    }
    if ("severity" in initData && initData["severity"].isString) {
      severity = toLower(initData["severity"].get!string);
    }
    if ("category" in initData && initData["category"].isString) {
      category = toLower(initData["category"].get!string);
    }
    if ("message" in initData && initData["message"].isString) {
      message = initData["message"].get!string;
    }
    if ("source_service" in initData && initData["source_service"].isString) {
      sourceService = initData["source_service"].get!string;
    }
    if ("actor" in initData && initData["actor"].isString) {
      actor = initData["actor"].get!string;
    }
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

  AuditLogEvent eventFromJson(string tenantId, Json request) {
    AuditLogEvent eventItem = new AuditLogEvent(request);

    eventItem.tenantId = UUID(tenantId);
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
