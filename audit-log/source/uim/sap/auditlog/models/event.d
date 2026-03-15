module uim.sap.auditlog.models.event;
import uim.sap.auditlog;

mixin(ShowModule!());

@safe:

struct AuditLogEvent {
  UUID tenantId;
  UUID eventId;
  string eventType;
  string severity;
  string category;
  string message;
  string sourceService;
  string actor;
  Json details;
  SysTime createdAt;

  override Json toJson()  {
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["event_id"] = eventId;
    result["event_type"] = eventType;
    result["severity"] = severity;
    result["category"] = category;
    result["message"] = message;
    result["source_service"] = sourceService;
    result["actor"] = actor;
    result["details"] = details;
    result["created_at"] = createdAt.toISOExtString();
    result["recommended_type"] = isRecommendedAuditEventType(eventType);
    return result;
  }
}

AuditLogEvent eventFromJson(string tenantId, Json request) {
  AuditLogEvent eventItem;
  eventItem.tenantId = UUID(tenantId);
  eventItem.eventId = randomUUID().toString();
  eventItem.eventType = "system_event";
  eventItem.severity = "info";
  eventItem.category = "audit";
  eventItem.sourceService = "unknown";
  eventItem.actor = "system";
  eventItem.details = Json.emptyObject;
  eventItem.createdAt = Clock.currTime();

  if ("event_id" in request && request["event_id"].isString) {
    eventItem.eventId = request["event_id"].get!string;
  }
  if ("event_type" in request && request["event_type"].isString) {
    eventItem.eventType = toLower(request["event_type"].get!string);
  }
  if ("severity" in request && request["severity"].isString) {
    eventItem.severity = toLower(request["severity"].get!string);
  }
  if ("category" in request && request["category"].isString) {
    eventItem.category = toLower(request["category"].get!string);
  }
  if ("message" in request && request["message"].isString) {
    eventItem.message = request["message"].get!string;
  }
  if ("source_service" in request && request["source_service"].isString) {
    eventItem.sourceService = request["source_service"].get!string;
  }
  if ("actor" in request && request["actor"].isString) {
    eventItem.actor = request["actor"].get!string;
  }
  if ("details" in request && request["details"].isObject) {
    eventItem.details = request["details"];
  }

  return eventItem;
}
