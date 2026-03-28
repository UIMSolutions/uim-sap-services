module uim.sap.bas.models.wizardrun;

import uim.sap.bas;

mixin(ShowModule!());

@safe:


class BASWizardRun : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!BASWizardRun);

  UUID runId;
  UUID workspaceId;
  UUID templateId;
  string status;
  Json input;
  Json output;
  SysTime startedAt;
  SysTime finishedAt;

  override Json toJson()  {
    return super.toJson()
      .set("run_id", runId)
      .set("workspace_id", workspaceId)
      .set("template_id", templateId)
      .set("status", status)
      .set("input", input)
      .set("output", output)
      .set("started_at", startedAt.toISOExtString())
      .set("finished_at", finishedAt.toISOExtString());
  }
}
