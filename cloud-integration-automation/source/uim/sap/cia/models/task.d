module uim.sap.cia.models.task;

import uim.sap.cia;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// Task – a single guided step in a workflow
// ---------------------------------------------------------------------------
class CIATask : SAPTenantEntity {
mixin(SAPEntityTemplate!CIATask);

  UUID workflowId;
  UUID id;
  int order;
  string name;
  string description;
  /// Full instructions rendered for the assignee (may include parameter values)
  string instructions;
  UUID assignedRoleId;
  UUID assignedUserId;
  bool automated;
  /// Status: "pending" | "in-progress" | "done" | "skipped" | "failed"
  string status;
  /// Additional runtime context (e.g. target system id, config payload)
  Json context;

  override Json toJson()  {
    return super.toJson
    .set("workflow_id", workflowId)
    .set("id", id)
    .set("order", order)
    .set("name", name)
    .set("description", description)
    .set("instructions", instructions)
    .set("assigned_role_id", assignedRoleId)
    .set("assigned_user_id", assignedUserId)
    .set("automated", automated)
    .set("status", status)
    .set("context", context);
  }
}