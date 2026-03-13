module uim.sap.auditlog.models.retentionpolicy;
import uim.sap.auditlog;

mixin(ShowModule!());

@safe:

struct AuditLogRetentionPolicy {
    string tenantId;
    int retentionDays;
    string plan;
    double premiumCostPerThousandEvents;
    SysTime updatedAt;

    Json toJson() const {
        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["retention_days"] = retentionDays;
        result["plan"] = plan;
        result["premium_cost_per_1000_events"] = premiumCostPerThousandEvents;
        result["updated_at"] = updatedAt.toISOExtString();
        return result;
    }
}