/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.migration;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct INTMigration {
  string tenantId;
  string migrationId;
  string name;
  string description;
  string sourceSystem = "PO"; // PO | PI | XI
  string sourceVersion;
  string scenarioType = "iflow"; // iflow | bpm | b2b | mapping
  string complexity = "medium"; // low | medium | high | critical
  long estimatedHours = 0;
  string status = "pending"; // pending | in_progress | completed | failed
  string targetRuntime = "cloud"; // cloud | hybrid
  Json scenarioDetails;
  string assessedAt;
  string completedAt;
  string createdAt;
  string updatedAt;

  Json toJson() const {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["migration_id"] = migrationId;
    j["name"] = name;
    j["description"] = description;
    j["source_system"] = sourceSystem;
    j["source_version"] = sourceVersion;
    j["scenario_type"] = scenarioType;
    j["complexity"] = complexity;
    j["estimated_hours"] = estimatedHours;
    j["status"] = status;
    j["target_runtime"] = targetRuntime;
    j["scenario_details"] = scenarioDetails;
    j["assessed_at"] = assessedAt;
    j["completed_at"] = completedAt;
    j["created_at"] = createdAt;
    j["updated_at"] = updatedAt;
    return j;
  }
}

INTMigration migrationFromJson(string tenantId, Json request) {
  INTMigration m;
  m.tenantId = tenantId;
  m.migrationId = randomUUID().toString();

  if ("name" in request && request["name"].isString)
    m.name = request["name"].get!string;
  if ("description" in request && request["description"].isString)
    m.description = request["description"].get!string;
  if ("source_system" in request && request["source_system"].isString)
    m.sourceSystem = request["source_system"].get!string;
  if ("source_version" in request && request["source_version"].isString)
    m.sourceVersion = request["source_version"].get!string;
  if ("scenario_type" in request && request["scenario_type"].isString)
    m.scenarioType = request["scenario_type"].get!string;
  if ("complexity" in request && request["complexity"].isString)
    m.complexity = request["complexity"].get!string;
  if ("estimated_hours" in request && request["estimated_hours"].type == Json.Type.int_)
    m.estimatedHours = request["estimated_hours"].get!long;
  if ("target_runtime" in request && request["target_runtime"].isString)
    m.targetRuntime = request["target_runtime"].get!string;
  if ("scenario_details" in request)
    m.scenarioDetails = request["scenario_details"];
  else
    m.scenarioDetails = Json.emptyObject;

  m.createdAt = Clock.currTime().toINTOExtString();
  m.updatedAt = m.createdAt;
  return m;
}
