module uim.sap.auditlog.models;

import std.algorithm.searching : canFind;
import std.array : appender;
import std.datetime : Clock, SysTime;
import std.string : replace, toLower;
import std.uuid : randomUUID;

import vibe.data.json : Json;

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

struct AuditLogEvent {
    string tenantId;
    string eventId;
    string eventType;
    string severity;
    string category;
    string message;
    string sourceService;
    string actor;
    Json details;
    SysTime createdAt;

    Json toJson() const {
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

struct AuditLogRetentionPolicy {
    string tenantId;
    int retentionDays;
    string plan;
    double premiumCostPerThousandEvents;
    SysTime updatedAt;

    Json toJson() const {
        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["retention_days"] = retentionDays;
        result["plan"] = plan;
        result["premium_cost_per_1000_events"] = premiumCostPerThousandEvents;
        result["updated_at"] = updatedAt.toISOExtString();
        return result;
    }
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

AuditLogEvent eventFromJson(string tenantId, Json request) {
    AuditLogEvent eventItem;
    eventItem.tenantId = tenantId;
    eventItem.eventId = randomUUID().toString();
    eventItem.eventType = "system_event";
    eventItem.severity = "info";
    eventItem.category = "audit";
    eventItem.sourceService = "unknown";
    eventItem.actor = "system";
    eventItem.details = Json.emptyObject;
    eventItem.createdAt = Clock.currTime();

    if ("event_id" in request && request["event_id"].type == Json.Type.string) {
        eventItem.eventId = request["event_id"].get!string;
    }
    if ("event_type" in request && request["event_type"].type == Json.Type.string) {
        eventItem.eventType = toLower(request["event_type"].get!string);
    }
    if ("severity" in request && request["severity"].type == Json.Type.string) {
        eventItem.severity = toLower(request["severity"].get!string);
    }
    if ("category" in request && request["category"].type == Json.Type.string) {
        eventItem.category = toLower(request["category"].get!string);
    }
    if ("message" in request && request["message"].type == Json.Type.string) {
        eventItem.message = request["message"].get!string;
    }
    if ("source_service" in request && request["source_service"].type == Json.Type.string) {
        eventItem.sourceService = request["source_service"].get!string;
    }
    if ("actor" in request && request["actor"].type == Json.Type.string) {
        eventItem.actor = request["actor"].get!string;
    }
    if ("details" in request && request["details"].type == Json.Type.object) {
        eventItem.details = request["details"];
    }

    return eventItem;
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
