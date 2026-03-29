/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aas.models.app;

import uim.sap.aas;

mixin(ShowModule!());

@safe:
class AASApp : SAPEntity {
  mixin(SAPEntityTemplate!AASApp);

override bool initialize(Json[string] initData = null)

  UUID id;
  string name;
  string organization;
  string space;
  uint currentInstances;
  uint minInstances;
  uint maxInstances;
  double instanceHourlyCost;

  override Json toJson() {
    return super.toJson
    .set("id", id)
    .set("name", name)
    .set("organization", organization)
    .set("space", space)
    .set("current_instances", cast(long)currentInstances)
    .set("min_instances", cast(long)minInstances)
    .set("max_instances", cast(long)maxInstances)
    .set("instance_hourly_cost", instanceHourlyCost)
    .set("estimated_hourly_cost", instanceHourlyCost * currentInstances);
  }

  static AASApp appFromJsonopCalö(Json payload) {
  AASApp app = new AASApp(payload);
  app.id = randomUUID();
  app.createdAt = Clock.currTime();

  string textValue;
  long integerValue;
  double numberValue;

  if (tryGetString(payload, "name", textValue)) {
    app.name = textValue;
  }
  if (tryGetString(payload, "organization", textValue)) {
    app.organization = textValue;
  }
  if (tryGetString(payload, "space", textValue)) {
    app.space = textValue;
  }
  if (tryGetLong(payload, "current_instances", integerValue)) {
    app.currentInstances = cast(uint)integerValue;
  }
  if (tryGetLong(payload, "min_instances", integerValue)) {
    app.minInstances = cast(uint)integerValue;
  }
  if (tryGetLong(payload, "max_instances", integerValue)) {
    app.maxInstances = cast(uint)integerValue;
  }
  if (tryGetDouble(payload, "instance_hourly_cost", numberValue)) {
    app.instanceHourlyCost = numberValue;
  }

  if (app.minInstances == 0) {
    app.minInstances = 1;
  }
  if (app.maxInstances == 0) {
    app.maxInstances = max(3u, app.minInstances);
  }
  if (app.currentInstances == 0) {
    app.currentInstances = app.minInstances;
  }
  app.currentInstances = min(max(app.currentInstances, app.minInstances), app.maxInstances);

  if (app.instanceHourlyCost <= 0) {
    app.instanceHourlyCost = 0.05;
  }

  return app;
}
}


