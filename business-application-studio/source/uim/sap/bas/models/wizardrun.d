module uim.sap.bas.models.wizardrun;

import uim.sap.bas;

mixin(ShowModule!());

@safe:


struct BASWizardRun {
  string tenantId;
  string runId;
  string workspaceId;
  string templateId;
  string status;
  Json input;
  Json output;
  SysTime startedAt;
  SysTime finishedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["run_id"] = runId;
    payload["workspace_id"] = workspaceId;
    payload["template_id"] = templateId;
    payload["status"] = status;
    payload["input"] = input;
    payload["output"] = output;
    payload["started_at"] = startedAt.toISOExtString();
    payload["finished_at"] = finishedAt.toISOExtString();
    return payload;
  }
}
