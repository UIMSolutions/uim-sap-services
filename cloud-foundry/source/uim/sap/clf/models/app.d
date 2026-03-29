/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.models.app;

import uim.sap.clf;

mixin(ShowModule!());

@safe:
class CLFApp : SAPEntity {
  mixin(SAPEntityTemplate!CLFApp);

  string guid;
  string name;
  string spaceGuid;
  string state = "STOPPED";
  uint instances = 1;
  uint memoryMb = 256;
  
  override Json toJson()  {
    return super.toJson
    .set("guid", guid)
    .set("name", name)
    .set("space_guid", spaceGuid)
    .set("state", state)
    .set("instances", cast(long)instances)
    .set("memory_mb", cast(long)memoryMb);
  }

  static CLFApp opCall(Json payload) {
  CLFApp app = new CLFApp(payload);
  app.guId = randomUUID();
  app.createdAt = Clock.currTime();
  if ("name" in payload && payload["name"].isString) {
    app.name = payload["name"].getString;
  }
  if ("space_guid" in payload && payload["space_guid"].isString) {
    app.spaceGuid = payload["space_guid"].getString;
  }
  if ("state" in payload && payload["state"].isString) {
    app.state = payload["state"].getString;
  }
  if ("instances" in payload && payload["instances"].isInteger) {
    auto parsed = payload["instances"].get!long;
    if (parsed > 0) {
      app.instances = cast(uint)parsed;
    }
  }
  if ("memory_mb" in payload && payload["memory_mb"].isInteger) {
    auto parsed = payload["memory_mb"].get!long;
    if (parsed > 0) {
      app.memoryMb = cast(uint)parsed;
    }
  }
  return app;
}
}
///
unittest {
  Json payload = Json.emptyObject
    .set("name", "my-app")
    .set("space_guid", "space-123")
    .set("state", "STARTED")
    .set("instances", 2)
    .set("memory_mb", 512);

  CLFApp app = CLFApp(payload);
  assert(app.name == "my-app");
  assert(app.spaceGuid == "space-123");
  assert(app.state == "STARTED");
  assert(app.instances == 2);
  assert(app.memoryMb == 512);
}