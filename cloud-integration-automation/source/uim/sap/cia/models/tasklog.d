module uim.sap.cia.models.tasklog;

import uim.sap.cia;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// TaskLog – a monitoring log entry for a workflow or task
// ---------------------------------------------------------------------------
class CIATaskLog : SAPTenantEntity {
mixin(SAPEntityTemplate!CIATaskLog);

  UUID workflowId;
  UUID taskId; // empty string if workflow-level log
  UUID id;
  string message;
  /// Level: "info" | "warning" | "error"
  string level;
  SysTime timestamp;

  override Json toJson()  {
    return super.toJson()
    .set("workflow_id", workflowId)
    .set("task_id", taskId)
    .set("id", id)
    .set("message", message)
    .set("level", level)
    .set("timestamp", timestamp.toISOExtString());
  }
}