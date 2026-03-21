/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.dpi.models.retentionrule;

import uim.sap.dpi;

mixin(ShowModule!());

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
class DPIRetentionRule : SAPTenantObject {
  mixin(SAPObjectTemplate!DPIRetentionRule);

  UUID ruleId;
  string dataCategory;
  int retentionDays;
  bool active;
  SysTime updatedAt;

  override Json toJson()  {
    return super.toJson
    .set("rule_id", ruleId)
    .set("data_category", dataCategory)
    .set("retention_days", retentionDays)
    .set("active", active);
  }
}
