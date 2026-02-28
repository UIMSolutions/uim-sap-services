module uim.sap.cis.models.provisioningjob;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

struct CISProvisioningJob {
  string tenantId;
  string jobId;
  string sourceSystem;
  string targetSystem;
  string mode;
  string status;
  Json filters;
  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["job_id"] = jobId;
    payload["tenant_id"] = tenantId;
    payload["source_system"] = sourceSystem;
    payload["target_system"] = targetSystem;
    payload["mode"] = mode;
    payload["status"] = status;
    payload["filters"] = filters;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
