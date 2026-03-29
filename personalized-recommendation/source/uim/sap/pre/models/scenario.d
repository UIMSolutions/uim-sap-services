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
class PREScenario : SAPTenantEntity {
  mixin(SAPTenantEntity!PREScenario);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }
    if ("scenarioId" in initData && initData["scenarioId"].isString) {
      scenarioId = initData["scenarioId"].getString;
    }
    if ("name" in initData && initData["name"].isString) {
      name = initData["name"].getString;
    }
    if ("description" in initData && initData["description"].isString) {
      description = initData["description"].getString;
    }
    if ("scenarioType" in initData && initData["scenarioType"].isString) {
      scenarioType = PREScenarioType.fromString(initData["scenarioType"].getString);
    }
    if ("modelId" in initData && initData["modelId"].isString) {
      modelId = initData["modelId"].getString;
    }
    if ("active" in initData && initData["active"].isBool) {
      active = initData["active"].getBool;
    }
    if ("config" in initData && initData["config"].isObject) {
      foreach (k, v; initData["config"].toObject) {
        if (v.isString) {
          config[k] = v.getString;
        }
      }
    }

    scenarioId = initData.getString("scenarioId", "");
    tenantId = initData.getString("tenantId", "");
    name = initData.getString("name", "");
    description = initData.getString("description", "");
    if ("modelId" in initData)
      modelId = initData["modelId"].getString;
    if ("active" in initData)
      active = initData["active"].get!bool;
    if ("config" in initData) {
      foreach (string k, v; initData["config"].toMap)
        config[k] = v.getString;
    }

    return true;
  }

  string scenarioId;
  string name;
  string description;
  PREScenarioType scenarioType = PREScenarioType.ecommerce;
  string modelId;
  bool active = true;
  string[string] config;

  override Json toJson() {
    Json obj = Json.emptyObject;
    foreach (k, v; config)
      obj[k] = v;

    return super.toJson
      .set("scenarioId", scenarioId)
      .set("name", name)
      .set("description", description)
      .set("scenarioType", scenarioType.to!string)
      .set("modelId", modelId)
      .set("active", active)
      .set("config", obj);
  }

  PREScenario scenarioFromJson(Json initData) {
    PREScenario scenario = new PREScenario(initData);
    return scenario;
  }
}
