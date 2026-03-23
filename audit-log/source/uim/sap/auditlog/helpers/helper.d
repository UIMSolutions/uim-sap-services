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

class AuditLogWriteResult : SAPObject {
  mixin(SAPObjectTemplate!AuditLogWriteResult);

  bool success;
  UUID eventId;
  bool recommendedType;

  override Json toJson() {
    return super.toJson
      .set("success", success)
      .set("event_id", eventId)
      .set("recommended_type", recommendedType);
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
