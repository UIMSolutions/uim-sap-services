module uim.sap.bas.models.terminalsession;

import uim.sap.bas;

mixin(ShowModule!());

@safe:


struct BASTerminalSession {
  UUID tenantId;
  UUID workspaceId;
  UUID sessionId;
  string shell;
  string status;
  SysTime createdAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["workspace_id"] = workspaceId;
    payload["session_id"] = sessionId;
    payload["shell"] = shell;
    payload["status"] = status;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}