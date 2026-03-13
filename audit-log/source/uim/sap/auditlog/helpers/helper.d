module uim.sap.auditlog.helpers.helper;
import uim.sap.auditlog;

mixin(ShowModule!());

@safe:

enum string[] AUDIT_LOG_RECOMMENDED_EVENT_TYPES = [
    "data_access",
    "data_modification",
    "security_event",
    "configuration_change",
    "user_management",
    "system_event"
  ];

bool isRecommendedAuditEventType(string eventType) {
  return AUDIT_LOG_RECOMMENDED_EVENT_TYPES.canFind(toLower(eventType));
}

struct AuditLogWriteResult {
  bool success;
  string eventId;
  bool recommendedType;

  Json toJson() const {
    Json result = Json.emptyObject;
    result["success"] = success;
    result["event_id"] = eventId;
    result["recommended_type"] = recommendedType;
    return result;
  }
}

string toCsv(AuditLogEvent[] events) {
  auto builder = appender!string;
  builder.put("event_id,event_type,severity,category,source_service,actor,created_at,message\n");
  foreach (eventItem; events) {
    builder.put(eventItem.eventId ~ ",");
    builder.put(eventItem.eventType ~ ",");
    builder.put(eventItem.severity ~ ",");
    builder.put(eventItem.category ~ ",");
    builder.put(eventItem.sourceService ~ ",");
    builder.put(eventItem.actor ~ ",");
    builder.put(eventItem.createdAt.toISOExtString() ~ ",");
    builder.put(escapeCsv(eventItem.message));
    builder.put("\n");
  }
  return builder.data;
}

private string escapeCsv(string value) {
  auto escaped = value.replace("\"", "\"\"");
  return "\"" ~ escaped ~ "\"";
}
