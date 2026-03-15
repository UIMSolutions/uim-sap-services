module uim.sap.dpi.models.retentionrule;

import std.sap.dpi;

@safe:

/** 
 * Represents a data retention rule for a specific data category.
 * Each rule defines how long data of a certain category should be retained before deletion.
 *
 * Fields:
 * - tenantId: The ID of the tenant this rule applies to.
 * - ruleId: A unique identifier for the retention rule.
 * - dataCategory: The category of data this rule applies to (e.g., "customer_data", "transaction_data").
 * - retentionDays: The number of days data in this category should be retained before it is eligible for deletion.
 * - active: A boolean indicating whether the rule is currently active.
 * - updatedAt: The timestamp of the last update to this rule.  
 */
struct DPIRetentionRule {
  string tenantId;
  string ruleId;
  string dataCategory;
  int retentionDays;
  bool active;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["rule_id"] = ruleId;
    payload["data_category"] = dataCategory;
    payload["retention_days"] = retentionDays;
    payload["active"] = active;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
