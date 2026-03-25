/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pre.models.scenario;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

/// A business scenario that ties a model to a recommendation use-case.
struct PREScenario {
  string scenarioId;
  UUID tenantId;
  string name;
  string description;
  PREScenarioType scenarioType = PREScenarioType.ecommerce;
  string modelId;
  bool active = true;
  string[string] config;
  string createdAt;
  string updatedAt;
}

Json scenarioToJson(const ref PREScenario s) {
  Json obj = Json.emptyObject;
  foreach (k, v; s.config)
    obj[k] = v;

  return Json.emptyObject
  .set("scenarioId", s.scenarioId)
  .set("tenantId", s.tenantId)
  .set("name", s.name)
  .set("description", s.description)
  .set("scenarioType", s.scenarioType.to!string)
  .set("modelId", s.modelId)
  .set("active", s.active)
  .set("config", obj)
  .set("createdAt", s.createdAt)
  .set("updatedAt", s.updatedAt);
}

PREScenario scenarioFromJson(Json j) {
  PREScenario s = new PREScenario(j);
  s.scenarioId = j.getString("scenarioId", "");
  s.tenantId = j.getString("tenantId", "");
  s.name = j["name"].get!string;
  s.description = j.getString("description", "");
  if ("modelId" in j)
    s.modelId = j["modelId"].get!string;
  if ("active" in j)
    s.active = j["active"].get!bool;
  if ("config" in j) {
    foreach (string k, v; j["config"].toMap)
      s.config[k] = v.get!string;
  }
  return s;
}
