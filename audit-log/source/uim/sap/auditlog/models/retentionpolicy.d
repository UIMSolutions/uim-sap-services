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
class ADLRetentionPolicy : SAPTenantObject {
  mixin(SAPObjectTemplate!ADLRetentionPolicy);

  int retentionDays;
  string plan;
  double premiumCostPerThousandEvents;
  SysTime updatedAt;

  override Json toJson() {
    Json result = super.toJson;
    
    result["retention_days"] = retentionDays.toJson;
    result["plan"] = plan.toJson;
    result["premium_cost_per_1000_events"] = premiumCostPerThousandEvents.toJson;
    result["updated_at"] = updatedAt.toISOExtString().toJson;

    return result;
  }
}
