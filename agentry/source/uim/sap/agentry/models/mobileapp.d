module uim.sap.agentry.models.mobileapp;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

class AgentryMobileApp : SAPTenantObject {
  mixin(SAPObjectTemplate!AgentryMobileApp);

  UUID appId;
  string name;
  string backendSystem;
  string ownerTeam;
  string lifecycle = "development";

  override override Json toJson()  {
    Json result = super.toJson();
    result["app_id"] = appId.toJson;
    result["name"] = name;
    result["backend_system"] = backendSystem;
    result["owner_team"] = ownerTeam;
    result["lifecycle"] = lifecycle;
    return result;
  }
}

AgentryMobileApp appFromJson(string tenantId, Json request, string defaultBackend) {
  AgentryMobileApp app;
  app.tenantId = tenantId;
  app.appId = randomUUID().toString();
  app.backendSystem = defaultBackend;
  app.createdAt = Clock.currTime();
  app.updatedAt = app.createdAt;

  if ("app_id" in request && request["app_id"].isString) {
    app.appId = request["app_id"].get!string;
  }
  if ("name" in request && request["name"].isString) {
    app.name = request["name"].get!string;
  }
  if ("backend_system" in request && request["backend_system"].isString) {
    app.backendSystem = request["backend_system"].get!string;
  }
  if ("owner_team" in request && request["owner_team"].isString) {
    app.ownerTeam = request["owner_team"].get!string;
  }
  if ("lifecycle" in request && request["lifecycle"].isString) {
    app.lifecycle = toLower(request["lifecycle"].get!string);
  }

  return app;
}









