module uim.sap.bas.models.terminalsession;

import uim.sap.bas;

mixin(ShowModule!());

@safe:

class BASTerminalSession : SAPTenantObject {
  mixin(SAPObjectTemplate!BASTerminalSession);

  UUID workspaceId;
  UUID sessionId;
  string shell;
  string status;
  SysTime createdAt;

  override Json toJson() {
    return super.toJson
      .set("tenant_id", tenantId)
      .set("workspace_id", workspaceId)
      .set("session_id", sessionId)
      .set("shell", shell)
      .set("status", status)
      .set("created_at", createdAt.toISOExtString());
  }
}
