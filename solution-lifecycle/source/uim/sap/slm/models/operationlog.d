module uim.sap.slm.models.operationlog;

// ---------------------------------------------------------------------------
// SLMOperationLog – audit/monitoring log for solution operations
// ---------------------------------------------------------------------------
class SLMOperationLog : SAPTenantObject {
  mixin(SAPObjectTemplate!SLMOperationLog);

  UUID tenantId;
  UUID logId;
  UUID solutionId;
  UUID deploymentId;
  /// Action: "deployed" | "updated" | "deleted" | "subscribed" | "unsubscribed" |
  ///         "component-started" | "component-stopped" | "error"
  string action;
  string message;
  /// Level: "info" | "warning" | "error"
  string level;
  SysTime timestamp;

  Json toJson() {
    return super.toJson
    .set("log_id", logId)
    .set("solution_id", solutionId)
    .set("deployment_id", deploymentId)
    .set("action", action)
    .set("message", message)
    .set("level", level)
    .set("timestamp", timestamp.toISOExtString());
  }
}