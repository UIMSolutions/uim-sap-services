module uim.sap.bas.models.deployment;

import uim.sap.bas;

mixin(ShowModule!());

@safe:

struct BASDeployment {
  string tenantId;
  string workspaceId;
  string deploymentId;
  string target;
  string mode;
  string status;
  SysTime createdAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["workspace_id"] = workspaceId;
    payload["deployment_id"] = deploymentId;
    payload["target"] = target;
    payload["mode"] = mode;
    payload["status"] = status;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}
