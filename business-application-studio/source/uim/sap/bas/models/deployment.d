module uim.sap.bas.models.deployment;

import uim.sap.bas;

mixin(ShowModule!());

@safe:

class BASDeployment : SAPTenantObject {
  mixin(SAPObjectTemplate!BASDeployment);

  UUID workspaceId;
  UUID deploymentId;
  string target;
  string mode;
  string status;

  override Json toJson()  {
    return super.toJson
      .set("workspace_id", workspaceId)
      .set("deployment_id", deploymentId)
      .set("target", target)
      .set("mode", mode)
      .set("status", status);
  }
}
