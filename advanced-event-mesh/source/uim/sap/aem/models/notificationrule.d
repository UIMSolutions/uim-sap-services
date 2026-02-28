module uim.sap.aem.models.notificationrule;

import uim.sap.aem;

mixin(ShowModule!());

@safe:


struct AEMNotificationRule {
    string tenantId;
    string ruleId;
    string metric;
    double threshold;
    string severity = "warning";
    bool enabled = true;
    string channel = "email";
    SysTime updatedAt;

    Json toJson() const {
        Json resultJson = Json.emptyObject;
        resultJson["tenant_id"] = tenantId;
        resultJson["rule_id"] = ruleId;
        resultJson["metric"] = metric;
        resultJson["threshold"] = threshold;
        resultJson["severity"] = severity;
        resultJson["enabled"] = enabled;
        resultJson["channel"] = channel;
        resultJson["updated_at"] = updatedAt.toISOExtString();
        return resultJson;
    }
}

AEMNotificationRule notificationRuleFromJson(string tenantId, string ruleId, Json request) {
  AEMNotificationRule rule;
  rule.tenantId = tenantId;
  rule.ruleId = ruleId;
  rule.metric = "queue_depth";
  rule.threshold = 100.0;
  rule.updatedAt = Clock.currTime();

  if ("metric" in request && request["metric"].isString) {
    rule.metric = toLower(request["metric"].get!string);
  }
  if ("threshold" in request && request["threshold"].isFloat) {
    rule.threshold = request["threshold"].get!double;
  } else if ("threshold" in request && request["threshold"].isInteger) {
    rule.threshold = cast(double)request["threshold"].get!long;
  }
  if ("severity" in request && request["severity"].isString) {
    rule.severity = toLower(request["severity"].get!string);
  }
  if ("enabled" in request && request["enabled"].type == Json.Type.bool_) {
    rule.enabled = request["enabled"].get!bool;
  }
  if ("channel" in request && request["channel"].isString) {
    rule.channel = request["channel"].get!string;
  }

  return rule;
}