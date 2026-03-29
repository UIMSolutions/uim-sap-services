module uim.sap.auditlog.models.retentionpolicy;
import uim.sap.auditlog;

mixin(ShowModule!());

@safe:

/**
  * Represents the retention policy for audit logs in ADL.
  *
  * retentionDays: The number of days to retain audit logs.
  * plan: The retention plan (e.g., "standard", "premium").
  * premiumCostPerThousandEvents: The cost for retaining 1000 events under the premium plan.
  * updatedAt: The timestamp of the last update to the retention policy.
  */
class ADLRetentionPolicy : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!ADLRetentionPolicy);

  int retentionDays;
  string plan;
  double premiumCostPerThousandEvents;

  override Json toJson() {
    return super.toJson
      .set("retention_days", retentionDays.toJson)
      .set("plan", plan.toJson)
      .set("premium_cost_per_1000_events", premiumCostPerThousandEvents.toJson);
  }
}
