/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.migration;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class INTMigration : SAPTenantObject {
  mixin(SAPObjectTemplate!INTMigration);

  UUID migrationId;
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

  override Json toJson() {
    return super.toJson()
      .set("migration_id", migrationId)
      .set("name", name)
      .set("description", description)
      .set("source_system", sourceSystem)
      .set("source_version", sourceVersion)
      .set("scenario_type", scenarioType)
      .set("complexity", complexity)
      .set("estimated_hours", estimatedHours)
      .set("status", status)
      .set("target_runtime", targetRuntime)
      .set("scenario_details", scenarioDetails)
      .set("assessed_at", assessedAt)
      .set("completed_at", completedAt);
  }

  static INTMigration migrationFromJson(UUID tenantId, Json request) {
    INTMigration m = new INTMigration(request);
    m.tenantId = tenantId;
    m.migrationId = randomUUID();

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
    if ("estimated_hours" in request && request["estimated_hours"].isInteger)
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

}
