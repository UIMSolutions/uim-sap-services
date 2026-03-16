module uim.sap.cia.models.tasklog;
import uim.sap.cia;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// TaskLog – a monitoring log entry for a workflow or task
// ---------------------------------------------------------------------------
struct CIATaskLog {
  string tenantId;
  string workflowId;
  string taskId; // empty string if workflow-level log
  string id;
  string message;
  /// Level: "info" | "warning" | "error"
  string level;
  SysTime timestamp;

  override Json toJson()  {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["workflow_id"] = workflowId;
    j["task_id"] = taskId;
    j["id"] = id;
    j["message"] = message;
    j["level"] = level;
    j["timestamp"] = timestamp.toISOExtString();
    return j;
  }
}