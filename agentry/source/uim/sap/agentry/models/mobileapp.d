/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.models.mobileapp;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

class AGTMobileApp : SAPTenantObject {
  mixin(SAPObjectTemplate!AGTMobileApp);

  UUID appId;
  string name;
  string backendSystem;
  string ownerTeam;
  string lifecycle = "development";

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("app_id" in initData && initData["app_id"].isString) {
      app.appId = initData["app_id"].get!string;
    }
    if ("name" in initData && initData["name"].isString) {
      app.name = initData["name"].get!string;
    }
    if ("backend_system" in initData && initData["backend_system"].isString) {
      app.backendSystem = initData["backend_system"].get!string;
    }
    if ("owner_team" in initData && initData["owner_team"].isString) {
      app.ownerTeam = initData["owner_team"].get!string;
    }
    if ("lifecycle" in initData && initData["lifecycle"].isString) {
      app.lifecycle = toLower(initData["lifecycle"].get!string);
    }

    return true;
  }

  override Json toJson() {
    return super.toJson()
      .set("app_id", appId.toJson)
      .set("name", name)
      .set("backend_system", backendSystem)
      .set("owner_team", ownerTeam)
      .set("lifecycle", lifecycle);
  }

  static AGTMobileApp opCall(string tenantId, Json request, string defaultBackend) {
    AGTMobileApp app = new AGTMobileApp(request);
    app.tenantId = UUID(tenantId);
    app.appId = randomUUID().toString();
    app.backendSystem = defaultBackend;
    app.createdAt = Clock.currTime();
    app.updatedAt = app.createdAt;

    return app;
  }
}
