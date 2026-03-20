module uim.sap.cia.models.automationresult;
import uim.sap.cia;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// AutomationResult – outcome of an automated technical configuration step
// ---------------------------------------------------------------------------
class CIAAutomationResult : SAPTenantObject {
mixin(SAPObjectTemplate!CIAAutomationResult);

  UUID workflowId;
  UUID taskId;
  UUID id;
  UUID targetSystemId;
  /// Status: "running" | "success" | "failure"
  string status;
  string output;
  SysTime startedAt;
  SysTime finishedAt;

  override Json toJson()  {
    return super.toJson
    .set("workflow_id", workflowId)
    .set("task_id", taskId)
    .set("id", id)
    .set("target_system_id", targetSystemId)
    .set("status", status)
    .set("output", output)
    .set("started_at", startedAt.toISOExtString())
    .set("finished_at", finishedAt.toISOExtString());
  }
}