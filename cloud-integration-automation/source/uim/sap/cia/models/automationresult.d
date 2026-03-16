module uim.sap.cia.models.automationresult;
import uim.sap.cia;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// AutomationResult – outcome of an automated technical configuration step
// ---------------------------------------------------------------------------
struct CIAAutomationResult {
  UUID tenantId;
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
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["workflow_id"] = workflowId;
    j["task_id"] = taskId;
    j["id"] = id;
    j["target_system_id"] = targetSystemId;
    j["status"] = status;
    j["output"] = output;
    j["started_at"] = startedAt.toISOExtString();
    j["finished_at"] = finishedAt.toISOExtString();
    return j;
  }
}