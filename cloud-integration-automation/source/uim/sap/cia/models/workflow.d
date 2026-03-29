module uim.sap.cia.models.workflow;

import uim.sap.cia;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// Workflow – a running instance of a scenario for a tenant
// ---------------------------------------------------------------------------
class CIAWorkflow : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!CIAWorkflow);

  UUID id;
  UUID scenarioId;
  string scenarioName;
  string name;
  /// Status: "planned" | "running" | "completed" | "failed"
  string status;
  /// IDs of systems selected for this workflow
  string[] systemIds;
  SysTime startedAt;
  SysTime finishedAt;

  override Json toJson() {
    Json s = Json.emptyArray;
    foreach (sysId; systemIds)
      s ~= sysId;

    return super.toJson()
      .set("id", id)
      .set("scenario_id", scenarioId)
      .set("scenario_name", scenarioName)
      .set("name", name)
      .set("status", status)
      .set("system_ids", s)
      .set("started_at", startedAt.toISOExtString())
      .set("finished_at", finishedAt.toISOExtString());
  }
}
