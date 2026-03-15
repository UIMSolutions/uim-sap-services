/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.models.notificationrule;

import uim.sap.aem;

mixin(ShowModule!());

@safe:


class AEMNotificationRule : SAPTenantObject {
    mixin(SAPObjectTemplate!AEMNotificationRule);

    string ruleId;
    string metric;
    double threshold;
    string severity = "warning";
    bool enabled = true;
    string channel = "email";

    override Json toJson() const {
        Json resultJson = super.toJson();

        resultJson["rule_id"] = ruleId;
        resultJson["metric"] = metric;
        resultJson["threshold"] = threshold;
        resultJson["severity"] = severity;
        resultJson["enabled"] = enabled;
        resultJson["channel"] = channel;

        return resultJson;
    }
}

AEMNotificationRule notificationRuleFromJson(string tenantId, string ruleId, Json request) {
  AEMNotificationRule rule = new AEMNotificationRule();
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
  if ("enabled" in request && request["enabled"].isBoolean) {
    rule.enabled = request["enabled"].get!bool;
  }
  if ("channel" in request && request["channel"].isString) {
    rule.channel = request["channel"].get!string;
  }

  return rule;
}