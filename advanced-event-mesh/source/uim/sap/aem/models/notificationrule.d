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
  mixin(SAPTenantObjectTemplate!AEMNotificationRule);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("rule_id" in request && request["rule_id"].isString) {
      ruleId = UUID(request["rule_id"].get!string);
    }
    if ("metric" in request && request["metric"].isString) {
      metric = toLower(request["metric"].get!string);
    }
    if ("threshold" in request && request["threshold"].isFloat) {
      threshold = request["threshold"].get!double;
    } else if ("threshold" in request && request["threshold"].isInteger) {
      threshold = cast(double)request["threshold"].get!long;
    }
    if ("severity" in request && request["severity"].isString) {
      severity = toLower(request["severity"].get!string);
    }
    if ("enabled" in request && request["enabled"].isBoolean) {
      enabled = request["enabled"].get!bool;
    }
    if ("channel" in request && request["channel"].isString) {
      channel = request["channel"].getString;
    }

    return true;
  }

  UUID ruleId;
  string metric;
  double threshold;
  string severity = "warning";
  bool enabled = true;
  string channel = "email";

  override override Json toJson() {
    return super.toJson()
      .set("rule_id", ruleId)
      .set("metric", metric)
      .set("threshold", threshold)
      .set("severity", severity)
      .set("enabled", enabled)
      .set("channel", channel);
  }

  static AEMNotificationRule notificationRuleFromJson(UUID tenantId, string ruleId, Json request) {
    AEMNotificationRule rule = new AEMNotificationRule();
    rule.tenantId = tenantId;
    rule.ruleId = ruleId;
    rule.metric = "queue_depth";
    rule.threshold = 100.0;
    rule.updatedAt = Clock.currTime();

    return rule;
  }
}
