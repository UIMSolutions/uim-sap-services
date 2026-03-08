module uim.sap.bas.models.workspace;

struct BASWorkspace {
  string tenantId;
  string workspaceId;
  string name;
  string scenarioId;
  string region;
  string status;
  string accessUrl;
  bool terminalEnabled;
  bool debugEnabled;
  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["workspace_id"] = workspaceId;
    payload["name"] = name;
    payload["scenario_id"] = scenarioId;
    payload["region"] = region;
    payload["status"] = status;
    payload["access_url"] = accessUrl;
    payload["terminal_enabled"] = terminalEnabled;
    payload["debug_enabled"] = debugEnabled;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
