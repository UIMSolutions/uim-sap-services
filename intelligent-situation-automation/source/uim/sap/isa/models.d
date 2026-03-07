module uim.sap.isa.models;

import std.algorithm.comparison : max;
import std.datetime : Clock, SysTime;
import std.uuid : randomUUID;

import vibe.data.json : Json;

enum SituationStatus {
    open,
    resolved,
    autoResolved
}

string situationStatusToString(SituationStatus status) {
    final switch (status) {
        case SituationStatus.open: return "open";
        case SituationStatus.resolved: return "resolved";
        case SituationStatus.autoResolved: return "auto_resolved";
    }
}

SituationStatus situationStatusFromString(string value) {
    switch (value) {
        case "open": return SituationStatus.open;
        case "resolved": return SituationStatus.resolved;
        case "auto_resolved": return SituationStatus.autoResolved;
        default: return SituationStatus.open;
    }
}

struct BusinessRule {
    string field;
    string op;
    string expected;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["field"] = field;
        payload["op"] = op;
        payload["expected"] = expected;
        return payload;
    }
}

struct AutomationConfiguration {
    string id;
    string tenantId;
    string name;
    string description;
    string situationType;
    bool enabled;
    int avgManualMinutes;
    double autoResolutionRate;
    BusinessRule[] businessRules;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json rules = Json.emptyArray;
        foreach (rule; businessRules) {
            rules ~= rule.toJson();
        }

        payload["id"] = id;
        payload["tenant_id"] = tenantId;
        payload["name"] = name;
        payload["description"] = description;
        payload["situation_type"] = situationType;
        payload["enabled"] = enabled;
        payload["avg_manual_minutes"] = avgManualMinutes;
        payload["auto_resolution_rate"] = autoResolutionRate;
        payload["business_rules"] = rules;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct SituationInstance {
    string id;
    string tenantId;
    string situationType;
    string templateId;
    string entityType;
    string entityId;
    SituationStatus status;
    string resolutionFlow;
    Json dataContext;
    SysTime occurredAt;
    SysTime resolvedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["id"] = id;
        payload["tenant_id"] = tenantId;
        payload["situation_type"] = situationType;
        payload["template_id"] = templateId;
        payload["entity_type"] = entityType;
        payload["entity_id"] = entityId;
        payload["status"] = situationStatusToString(status);
        payload["resolution_flow"] = resolutionFlow;
        payload["data_context"] = dataContext;
        payload["occurred_at"] = occurredAt.toISOExtString();
        if (resolvedAt != SysTime.init) {
            payload["resolved_at"] = resolvedAt.toISOExtString();
        } else {
            payload["resolved_at"] = "";
        }
        return payload;
    }
}

struct DataContextReport {
    string id;
    string tenantId;
    string title;
    string entityType;
    string situationType;
    string importedFrom;
    SysTime importedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["id"] = id;
        payload["tenant_id"] = tenantId;
        payload["title"] = title;
        payload["entity_type"] = entityType;
        payload["situation_type"] = situationType;
        payload["imported_from"] = importedFrom;
        payload["imported_at"] = importedAt.toISOExtString();
        return payload;
    }
}

AutomationConfiguration configFromJson(Json payload, string tenantId) {
    AutomationConfiguration config;
    config.id = randomUUID().toString();
    config.tenantId = tenantId;
    config.name = getString(payload, "name", "");
    config.description = getString(payload, "description", "");
    config.situationType = getString(payload, "situation_type", "");
    config.enabled = getBool(payload, "enabled", true);
    config.avgManualMinutes = getInt(payload, "avg_manual_minutes", 5);
    config.autoResolutionRate = getDouble(payload, "auto_resolution_rate", 0.75);
    config.businessRules = parseRules(payload);
    config.createdAt = Clock.currTime();
    config.updatedAt = config.createdAt;

    if (config.avgManualMinutes <= 0) {
        config.avgManualMinutes = 1;
    }
    if (config.autoResolutionRate < 0) {
        config.autoResolutionRate = 0;
    }
    if (config.autoResolutionRate > 1) {
        config.autoResolutionRate = 1;
    }

    return config;
}

AutomationConfiguration updateConfigFromJson(AutomationConfiguration current, Json payload) {
    auto updated = current;

    if ("name" in payload) {
        updated.name = getString(payload, "name", current.name);
    }
    if ("description" in payload) {
        updated.description = getString(payload, "description", current.description);
    }
    if ("situation_type" in payload) {
        updated.situationType = getString(payload, "situation_type", current.situationType);
    }
    if ("enabled" in payload) {
        updated.enabled = getBool(payload, "enabled", current.enabled);
    }
    if ("avg_manual_minutes" in payload) {
        updated.avgManualMinutes = max(1, getInt(payload, "avg_manual_minutes", current.avgManualMinutes));
    }
    if ("auto_resolution_rate" in payload) {
        auto rate = getDouble(payload, "auto_resolution_rate", current.autoResolutionRate);
        if (rate < 0) rate = 0;
        if (rate > 1) rate = 1;
        updated.autoResolutionRate = rate;
    }
    if ("business_rules" in payload) {
        updated.businessRules = parseRules(payload);
    }

    updated.updatedAt = Clock.currTime();
    return updated;
}

SituationInstance situationFromJson(Json payload, string tenantId) {
    SituationInstance instance;
    instance.id = randomUUID().toString();
    instance.tenantId = tenantId;
    instance.situationType = getString(payload, "situation_type", "");
    instance.templateId = getString(payload, "template_id", "");
    instance.entityType = getString(payload, "entity_type", "unknown");
    instance.entityId = getString(payload, "entity_id", randomUUID().toString());
    instance.status = situationStatusFromString(getString(payload, "status", "open"));
    instance.resolutionFlow = getString(payload, "resolution_flow", "manual_review");
    instance.occurredAt = Clock.currTime();

    if ("data_context" in payload && payload["data_context"].isObject) {
        instance.dataContext = payload["data_context"];
    } else {
        instance.dataContext = Json.emptyObject;
    }

    if (instance.status != SituationStatus.open) {
        instance.resolvedAt = Clock.currTime();
    }

    return instance;
}

private BusinessRule[] parseRules(Json payload) {
    BusinessRule[] rules;
    if (!("business_rules" in payload) || !payload["business_rules"].isArray) {
        return rules;
    }

    foreach (entry; payload["business_rules"]) {
        if (!entry.isObject) {
            continue;
        }

        BusinessRule rule;
        rule.field = getString(entry, "field", "");
        rule.op = getString(entry, "op", "equals");
        rule.expected = getString(entry, "expected", "");

        if (rule.field.length == 0) {
            continue;
        }
        rules ~= rule;
    }

    return rules;
}

private string getString(Json payload, string key, string fallback) {
    if (!(key in payload)) {
        return fallback;
    }
    try {
        return payload[key].get!string;
    } catch (Exception) {
        return fallback;
    }
}

private bool getBool(Json payload, string key, bool fallback) {
    if (!(key in payload)) {
        return fallback;
    }
    try {
        return payload[key].get!bool;
    } catch (Exception) {
        return fallback;
    }
}

private int getInt(Json payload, string key, int fallback) {
    if (!(key in payload)) {
        return fallback;
    }
    try {
        return cast(int)payload[key].get!long;
    } catch (Exception) {
        return fallback;
    }
}

private double getDouble(Json payload, string key, double fallback) {
    if (!(key in payload)) {
        return fallback;
    }
    try {
        return payload[key].get!double;
    } catch (Exception) {
        return fallback;
    }
}
