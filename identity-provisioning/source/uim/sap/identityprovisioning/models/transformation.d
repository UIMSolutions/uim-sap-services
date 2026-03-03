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
struct IPTransformation {
    string tenantId;
    string transformationId;
    string systemId;           // which system this rule belongs to
    string entityType = "user"; // "user" | "group"
    string sourceAttribute;    // attribute name in the source
    string targetAttribute;    // attribute name in the target
    string action = "map";     // "map" | "filter" | "skip" | "default"
    string condition;          // filter condition expression (e.g., "email endsWith @example.com")
    string defaultValue;       // value to use when action is "default"
    long priority = 0;         // evaluation order (lower = first)
    bool active = true;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["transformation_id"] = transformationId;
        j["system_id"] = systemId;
        j["entity_type"] = entityType;
        j["source_attribute"] = sourceAttribute;
        j["target_attribute"] = targetAttribute;
        j["action"] = action;
        j["condition"] = condition;
        j["default_value"] = defaultValue;
        j["priority"] = priority;
        j["active"] = active;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

IPTransformation transformationFromJson(string tenantId, Json request) {
    IPTransformation t;
    t.tenantId = tenantId;
    t.transformationId = randomUUID().toString();

    if ("system_id" in request && request["system_id"].type == Json.Type.string)
        t.systemId = request["system_id"].get!string;
    if ("entity_type" in request && request["entity_type"].type == Json.Type.string)
        t.entityType = request["entity_type"].get!string;
    if ("source_attribute" in request && request["source_attribute"].type == Json.Type.string)
        t.sourceAttribute = request["source_attribute"].get!string;
    if ("target_attribute" in request && request["target_attribute"].type == Json.Type.string)
        t.targetAttribute = request["target_attribute"].get!string;
    if ("action" in request && request["action"].type == Json.Type.string)
        t.action = request["action"].get!string;
    if ("condition" in request && request["condition"].type == Json.Type.string)
        t.condition = request["condition"].get!string;
    if ("default_value" in request && request["default_value"].type == Json.Type.string)
        t.defaultValue = request["default_value"].get!string;
    if ("priority" in request && request["priority"].type == Json.Type.int_)
        t.priority = request["priority"].get!long;
    if ("active" in request && request["active"].type == Json.Type.bool_)
        t.active = request["active"].get!bool;
    if ("transformation_id" in request && request["transformation_id"].type == Json.Type.string)
        t.transformationId = request["transformation_id"].get!string;

    t.createdAt = Clock.currTime().toISOExtString();
    t.updatedAt = t.createdAt;
    return t;
}
