module uim.sap.bas.models.workspace;

import uim.sap.bas;

mixin(ShowModule!());

@safe:

class BASWorkspace : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!BASWorkspace);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // workspaceId = parseUUID(initData["workspace_id"]);
    // name = initData["name"];
    // scenarioId = parseUUID(initData["scenario_id"]);
    // region = initData["region"];
    // status = initData["status"];
    // accessUrl = initData["access_url"];
    // terminalEnabled = parseBool(initData["terminal_enabled"]);
    // debugEnabled = parseBool(initData["debug_enabled"]);

    return true;
  }

  UUID workspaceId;
  string name;
  UUID scenarioId;
  string region;
  string status;
  string accessUrl;
  bool terminalEnabled;
  bool debugEnabled;

  override Json toJson() {
    return super.toJson
      .set("workspace_id", workspaceId)
      .set("name", name)
      .set("scenario_id", scenarioId)
      .set("region", region)
      .set("status", status)
      .set("access_url", accessUrl)
      .set("terminal_enabled", terminalEnabled)
      .set("debug_enabled", debugEnabled);
  }
}
