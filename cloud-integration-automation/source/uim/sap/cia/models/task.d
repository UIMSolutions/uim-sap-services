module uim.sap.cia.models.task;

// ---------------------------------------------------------------------------
// Task – a single guided step in a workflow
// ---------------------------------------------------------------------------
struct CIATask {
  UUID tenantId;
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
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson()  {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["workflow_id"] = workflowId;
    j["id"] = id;
    j["order"] = order;
    j["name"] = name;
    j["description"] = description;
    j["instructions"] = instructions;
    j["assigned_role_id"] = assignedRoleId;
    j["assigned_user_id"] = assignedUserId;
    j["automated"] = automated;
    j["status"] = status;
    j["context"] = context;
    j["created_at"] = createdAt.toISOExtString();
    j["updated_at"] = updatedAt.toISOExtString();
    return j;
  }
}