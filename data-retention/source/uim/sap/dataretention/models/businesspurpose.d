module uim.sap.dataretention.models.businesspurpose;

import std.datetime : Clock, SysTime;

import uim.sap.dataretention;

mixin(ShowModule!());

@safe:


struct BusinessPurposeRule {
  UUID tenantId;
  string purposeRuleId;
  string applicationGroup;
  string purposeName;
  string referenceDateField;
  LegalGroundRule[] legalGroundRules;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    Json grounds = legalGroundRules.map!(g => g.toJson()).array.toJson();

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("purpose_rule_id", purposeRuleId)
      .set("application_group", applicationGroup)
      .set("purpose_name", purposeName)
      .set("reference_date_field", referenceDateField)
      .set("legal_grounds", grounds)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }
}

BusinessPurposeRule parseBusinessPurposeRule(UUID tenantId, Json request) {
  BusinessPurposeRule rule;
  rule.tenantId = tenantId;
  rule.purposeRuleId = request.getString("purpose_rule_id", createId());
  rule.applicationGroup = request.getString("application_group", "");
  rule.purposeName = request.getString("purpose_name", "");
  rule.referenceDateField = request.getString("reference_date_field", "transaction_date");
  rule.createdAt = Clock.currTime();
  rule.updatedAt = rule.createdAt;

  if ("legal_grounds" in request && request["legal_grounds"].isArray) {
    foreach (item; request["legal_grounds"].toArray) {
      if (!item.isObject) {
        continue;
      }
      LegalGroundRule ground;
      ground.legalGround = item.getString("legal_ground", "");
      ground.residenceDays = cast(int)item.getInteger("residence_days", 0);
      ground.retentionDays = cast(int)item.getInteger("retention_days", 0);
      rule.legalGroundRules ~= ground;
    }
  }

  return rule;
}





