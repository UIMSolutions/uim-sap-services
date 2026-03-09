module uim.sap.cia.models.workflow;

// ---------------------------------------------------------------------------
// Workflow – a running instance of a scenario for a tenant
// ---------------------------------------------------------------------------
struct CIAWorkflow {
  string tenantId;
  string id;
  string scenarioId;
  string scenarioName;
  string name;
  /// Status: "planned" | "running" | "completed" | "failed"
  string status;
  /// IDs of systems selected for this workflow
  string[] systemIds;
  SysTime createdAt;
  SysTime updatedAt;
  SysTime startedAt;
  SysTime finishedAt;

  Json toJson() const {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["id"] = id;
    j["scenario_id"] = scenarioId;
    j["scenario_name"] = scenarioName;
    j["name"] = name;
    j["status"] = status;

    Json s = Json.emptyArray;
    foreach (sysId; systemIds)
      s ~= sysId;
    j["system_ids"] = s;

    j["created_at"] = createdAt.toISOExtString();
    j["updated_at"] = updatedAt.toISOExtString();
    j["started_at"] = startedAt.toISOExtString();
    j["finished_at"] = finishedAt.toISOExtString();
    return j;
  }
}