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
struct IPVTransformation {
  UUID tenantId;
  string transformationId;
  string systemId; // which system this rule belongs to
  string entityType = "user"; // "user" | "group"
  string sourceAttribute; // attribute name in the source
  string targetAttribute; // attribute name in the target
  string action = "map"; // "map" | "filter" | "skip" | "default"
  string condition; // filter condition expression (e.g., "email endsWith @example.com")
  string defaultValue; // value to use when action is "default"
  long priority = 0; // evaluation order (lower = first)
  bool active = true;
  string createdAt;
  string updatedAt;

  override Json toJson()  {
    return super.toJson()
    .set("tenant_id", tenantId)
    .set("transformation_id", transformationId)
    .set("system_id", systemId)
    .set("entity_type", entityType)
    .set("source_attribute", sourceAttribute)
    .set("target_attribute", targetAttribute)
    .set("action", action)
    .set("condition", condition)
    .set("default_value", defaultValue)
    .set("priority", priority)
    .set("active", active)
    .set("created_at", createdAt)
    .set("updated_at", updatedAt);
  }
}

IPVTransformation transformationFromJson(UUID tenantId, Json request) {
  IPVTransformation t;
  t.tenantId = UUID(tenantId);
  t.transformationId = randomUUID().toString();

  if ("system_id" in request && request["system_id"].isString)
    t.systemId = request["system_id"].get!string;
  if ("entity_type" in request && request["entity_type"].isString)
    t.entityType = request["entity_type"].get!string;
  if ("source_attribute" in request && request["source_attribute"].isString)
    t.sourceAttribute = request["source_attribute"].get!string;
  if ("target_attribute" in request && request["target_attribute"].isString)
    t.targetAttribute = request["target_attribute"].get!string;
  if ("action" in request && request["action"].isString)
    t.action = request["action"].get!string;
  if ("condition" in request && request["condition"].isString)
    t.condition = request["condition"].get!string;
  if ("default_value" in request && request["default_value"].isString)
    t.defaultValue = request["default_value"].get!string;
  if ("priority" in request && request["priority"].type == Json.Type.int_)
    t.priority = request["priority"].get!long;
  if ("active" in request && request["active"].type == Json.Type.bool_)
    t.active = request["active"].get!bool;
  if ("transformation_id" in request && request["transformation_id"].isString)
    t.transformationId = request["transformation_id"].get!string;

  t.createdAt = Clock.currTime().toISOExtString();
  t.updatedAt = t.createdAt;
  return t;
}
