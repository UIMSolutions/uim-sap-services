module uim.sap.mdg.models.qualityrule;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:

struct MDGQualityRule {
    string tenantId;
    string ruleId;
    string name;
    string field;
    string ruleType;
    bool enabled = true;
    Json options;
    SysTime updatedAt;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["rule_id"] = ruleId;
        payload["name"] = name;
        payload["field"] = field;
        payload["rule_type"] = ruleType;
        payload["enabled"] = enabled;
        payload["options"] = options;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

MDGQualityRule qualityRuleFromJson(string tenantId, string ruleId, Json request) {
    MDGQualityRule rule;
    rule.tenantId = UUID(tenantId);
    rule.ruleId = ruleId;
    rule.updatedAt = Clock.currTime();
    rule.options = Json.emptyObject;

    if ("name" in request && request["name"].isString) {
        rule.name = request["name"].get!string;
    }
    if ("field" in request && request["field"].isString) {
        rule.field = request["field"].get!string;
    }
    if ("rule_type" in request && request["rule_type"].isString) {
        rule.ruleType = toLower(request["rule_type"].get!string);
    }
    if ("enabled" in request && request["enabled"].isBoolean) {
        rule.enabled = request["enabled"].get!bool;
    }
    if ("options" in request && request["options"].isObject) {
        rule.options = request["options"];
    }

    return rule;
}