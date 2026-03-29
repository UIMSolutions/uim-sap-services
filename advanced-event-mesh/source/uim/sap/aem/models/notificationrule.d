/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.models.notificationrule;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

class AEMNotificationRule : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!AEMNotificationRule);

  this(UUID tenantId, UUID ruleId, Json initData) {
    super(initData);
    this.tenantId = tenantId;
    this.ruleId = ruleId;
  }

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("rule_id" in initData && initData["rule_id"].isString) {
      ruleId = UUID(initData["rule_id"].get!string);
    }
    if ("metric" in initData && initData["metric"].isString) {
      metric = toLower(initData["metric"].get!string);
    }
    if ("threshold" in initData && initData["threshold"].isFloat) {
      threshold = initData["threshold"].get!double;
    } else if ("threshold" in initData && initData["threshold"].isInteger) {
      threshold = cast(double)initData["threshold"].get!long;
    }
      severity = toLower(initData.getString("severity", "warning"));
    if ("enabled" in initData && initData["enabled"].isBoolean) {
      enabled = initData["enabled"].get!bool;
    }
      channel = initData.getString("channel", "email");

    return true;
  }

  UUID ruleId;
  string metric;
  double threshold;
  string severity;
  bool enabled = true;
  string channel;

  override Json toJson() {
    return super.toJson()
      .set("rule_id", ruleId)
      .set("metric", metric)
      .set("threshold", threshold)
      .set("severity", severity)
      .set("enabled", enabled)
      .set("channel", channel);
  }

  static AEMNotificationRule notificationRuleFromJson(UUID tenantId, UUID ruleId, Json request) {
    AEMNotificationRule rule = new AEMNotificationRule();
    rule.tenantId = tenantId;
    rule.ruleId = ruleId;
    rule.metric = "queue_depth";
    rule.threshold = 100.0;
    rule.updatedAt = Clock.currTime();

    return rule;
  }
}
