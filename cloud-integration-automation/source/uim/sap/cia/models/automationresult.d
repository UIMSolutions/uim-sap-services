module uim.sap.cia.models.automationresult;

// ---------------------------------------------------------------------------
// AutomationResult – outcome of an automated technical configuration step
// ---------------------------------------------------------------------------
struct CIAAutomationResult {
  string tenantId;
  string workflowId;
  string taskId;
  string id;
  string targetSystemId;
  /// Status: "running" | "success" | "failure"
  string status;
  string output;
  SysTime startedAt;
  SysTime finishedAt;

  Json toJson() const {
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