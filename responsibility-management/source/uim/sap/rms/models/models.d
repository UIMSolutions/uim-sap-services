module uim.sap.rms.models.models;

import std.datetime : Clock;
import std.string : toLower;

import vibe.data.json : Json;

enum RuleMode {
    condition,
    externalApi
}

struct TenantContext {
    string tenantId;
    string spaceId;
}

struct TeamTypeDef {
    string code;
    string name;
    string description;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["code"] = code;
        payload["name"] = name;
        payload["description"] = description;
        return payload;
    }
}

struct FunctionDef {
    string code;
    string name;
    string description;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["code"] = code;
        payload["name"] = name;
        payload["description"] = description;
        return payload;
    }
}

struct TeamMember {
    string userId;
    string displayName;
    bool isOwner;
    bool notificationsEnabled;
    string[] functions;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["user_id"] = userId;
        payload["display_name"] = displayName;
        payload["is_owner"] = isOwner;
        payload["notifications_enabled"] = notificationsEnabled;

        Json fn = Json.emptyArray;
        foreach (item; functions) {
            fn ~= item;
        }
        payload["functions"] = fn;
        return payload;
    }
}

struct Team {
    string id;
    string name;
    string typeCode;
    string categoryCode;
    string description;
    TeamMember[] members;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["id"] = id;
        payload["name"] = name;
        payload["type_code"] = typeCode;
        payload["category_code"] = categoryCode;
        payload["description"] = description;

        Json memberList = Json.emptyArray;
        foreach (member; members) {
            memberList ~= member.toJson();
        }
        payload["members"] = memberList;
        return payload;
    }
}

struct ResponsibilityRule {
    string id;
    string name;
    string contextType;
    string objectType;
    RuleMode mode;
    string conditionField;
    string conditionEquals;
    string externalApiRef;
    string teamId;
    string functionCode;
    bool enabled;
    int priority;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["id"] = id;
        payload["name"] = name;
        payload["context_type"] = contextType;
        payload["object_type"] = objectType;
        payload["mode"] = modeToString(mode);
        payload["condition_field"] = conditionField;
        payload["condition_equals"] = conditionEquals;
        payload["external_api_ref"] = externalApiRef;
        payload["team_id"] = teamId;
        payload["function_code"] = functionCode;
        payload["enabled"] = enabled;
        payload["priority"] = priority;
        payload["created_at"] = createdAt;
        payload["updated_at"] = updatedAt;
        return payload;
    }
}

struct DeterminationLog {
    string id;
    string timestamp;
    string tenantId;
    string spaceId;
    string contextType;
    string objectType;
    string documentId;
    string[] matchedRuleIds;
    string[] teamIds;
    string[] agents;
    string[] notifications;
    long durationMs;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["id"] = id;
        payload["timestamp"] = timestamp;
        payload["tenant_id"] = tenantId;
        payload["space_id"] = spaceId;
        payload["context_type"] = contextType;
        payload["object_type"] = objectType;
        payload["document_id"] = documentId;

        Json rules = Json.emptyArray;
        foreach (item; matchedRuleIds) rules ~= item;
        payload["matched_rule_ids"] = rules;

        Json teams = Json.emptyArray;
        foreach (item; teamIds) teams ~= item;
        payload["team_ids"] = teams;

        Json users = Json.emptyArray;
        foreach (item; agents) users ~= item;
        payload["agents"] = users;

        Json noteList = Json.emptyArray;
        foreach (item; notifications) noteList ~= item;
        payload["notifications"] = noteList;

        payload["duration_ms"] = durationMs;
        return payload;
    }
}

string modeToString(RuleMode mode) {
    return mode == RuleMode.externalApi ? "external_api" : "condition";
}

RuleMode modeFromString(string value) {
    return toLower(value) == "external_api" ? RuleMode.externalApi : RuleMode.condition;
}

string nowIso() {
    return Clock.currTime().toISOExtString();
}
