/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.identityprovisioning.models.transformation;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

/** A transformation/filter rule applied during provisioning.
 *
 *  Transformations control which entities are provisioned and how
 *  attribute values are mapped between source and target systems.
 *
 *  `entityType` values: "user", "group"
 *  `action` values: "map", "filter", "skip", "default"
 */
class IPVTransformation : SAPTenantEntity {
  mixin(SAPTenantEntity!IPVTransformation);
  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }
    if ("system_id" in request && request["system_id"].isString)
      systemId = request["system_id"].getString;
    if ("entity_type" in request && request["entity_type"].isString)
      entityType = request["entity_type"].getString;
    if ("source_attribute" in request && request["source_attribute"].isString)
      sourceAttribute = request["source_attribute"].getString;
    if ("target_attribute" in request && request["target_attribute"].isString)
      targetAttribute = request["target_attribute"].getString;
    if ("action" in request && request["action"].isString)
      action = request["action"].getString;
    if ("condition" in request && request["condition"].isString)
      condition = request["condition"].getString;
    if ("default_value" in request && request["default_value"].isString)
      defaultValue = request["default_value"].getString;
    if ("priority" in request && request["priority"].isInteger)
      priority = request["priority"].get!long;
    if ("active" in request && request["active"].isBoolean)
      active = request["active"].get!bool;
    if ("transformation_id" in request && request["transformation_id"].isString)
      transformationId = request["transformation_id"].getString;

    t.transformationId = randomUUID();

    if ("system_id" in request && request["system_id"].isString)
      t.systemId = request["system_id"].getString;
    if ("entity_type" in request && request["entity_type"].isString)
      t.entityType = request["entity_type"].getString;
    if ("source_attribute" in request && request["source_attribute"].isString)
      t.sourceAttribute = request["source_attribute"].getString;
    if ("target_attribute" in request && request["target_attribute"].isString)
      t.targetAttribute = request["target_attribute"].getString;
    if ("action" in request && request["action"].isString)
      t.action = request["action"].getString;
    if ("condition" in request && request["condition"].isString)
      t.condition = request["condition"].getString;
    if ("default_value" in request && request["default_value"].isString)
      t.defaultValue = request["default_value"].getString;
    if ("priority" in request && request["priority"].isInteger)
      t.priority = request["priority"].get!long;
    if ("active" in request && request["active"].isBoolean)
      t.active = request["active"].get!bool;
    if ("transformation_id" in request && request["transformation_id"].isString)
      t.transformationId = request["transformation_id"].getString;

    t.createdAt = Clock.currTime();
    t.updatedAt = t.createdAt;
    return true;
  }

  UUID transformationId;
  UUID systemId; // which system this rule belongs to
  string entityType = "user"; // "user" | "group"
  string sourceAttribute; // attribute name in the source
  string targetAttribute; // attribute name in the target
  string action = "map"; // "map" | "filter" | "skip" | "default"
  string condition; // filter condition expression (e.g., "email endsWith @example.com")
  string defaultValue; // value to use when action is "default"
  long priority = 0; // evaluation order (lower = first)
  bool active = true;

  override Json toJson() {
    return super.toJson()
      .set("transformation_id", transformationId)
      .set("system_id", systemId)
      .set("entity_type", entityType)
      .set("source_attribute", sourceAttribute)
      .set("target_attribute", targetAttribute)
      .set("action", action)
      .set("condition", condition)
      .set("default_value", defaultValue)
      .set("priority", priority)
      .set("active", active);
  }

  static IPVTransformation transformationFromJson(UUID tenantId, Json request) {
    IPVTransformation t = new IPVTransformation(request);
    t.tenantId = tenantId;

    return t;
  }
}
