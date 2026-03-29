module uim.sap.mdg.models.qualityrule;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:

class MDGQualityRule : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!MDGQualityRule);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("rule_id" in initData && initData["rule_id"].isString) {
      ruleId = UUID(initData["rule_id"].get!string);
    }
    if ("name" in initData && initData["name"].isString) {
      name = initData["name"].getString;
    }
    if ("field" in initData && initData["field"].isString) {
      field = initData["field"].getString;
    }
    if ("rule_type" in initData && initData["rule_type"].isString) {
      ruleType = toLower(initData["rule_type"].get!string);
    }
    if ("enabled" in initData && initData["enabled"].isBoolean) {
      enabled = initData["enabled"].get!bool;
    }
    if ("options" in initData && initData["options"].isObject) {
      options = initData["options"];
    }

    return true;
  }

  UUID ruleId;
  string name;
  string field;
  string ruleType;
  bool enabled = true;
  Json options;

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("rule_id", ruleId)
      .set("name", name)
      .set("field", field)
      .set("rule_type", ruleType)
      .set("enabled", enabled)
      .set("options", options);
  }

  static MDGQualityRule qualityRuleFromJson(UUID tenantId, string ruleId, Json request) {
    MDGQualityRule rule = new MDGQualityRule(request);
    rule.tenantId = tenantId;
    rule.ruleId = ruleId;
    rule.updatedAt = Clock.currTime();
    rule.options = Json.emptyObject;

    return rule;
  }
}
