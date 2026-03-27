module uim.sap.mdg.models.qualityrule;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:

class MDGQualityRule : SAPTenantObject {
  mixin(SAPtenantObject!MDGQualityRule);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("rule_id" in request && request["rule_id"].isString) {
      ruleId = UUID(request["rule_id"].get!string);
    }
    if ("name" in request && request["name"].isString) {
      name = request["name"].get!string;
    }
    if ("field" in request && request["field"].isString) {
      field = request["field"].get!string;
    }
    if ("rule_type" in request && request["rule_type"].isString) {
      ruleType = toLower(request["rule_type"].get!string);
    }
    if ("enabled" in request && request["enabled"].isBoolean) {
      enabled = request["enabled"].get!bool;
    }
    if ("options" in request && request["options"].isObject) {
      options = request["options"];
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
