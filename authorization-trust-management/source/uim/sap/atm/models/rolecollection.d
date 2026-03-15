module uim.sap.atm.models.rolecollection;

struct ATMRoleCollection {
  UUID tenantId;
  UUID collectionId;
  string name;
  string description;
  string[] technicalRoleIds;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    Json roleRefs = Json.emptyArray;
    foreach (roleId; technicalRoleIds) {
      roleRefs ~= roleId;
    }

    payload["tenant_id"] = tenantId;
    payload["collection_id"] = collectionId;
    payload["name"] = name;
    payload["description"] = description;
    payload["technical_role_ids"] = roleRefs;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

ATMRoleCollection roleCollectionFromJson(string tenantId, string collectionId, Json request) {
  ATMRoleCollection collection;
  collection.tenantId = tenantId;
  collection.collectionId = collectionId.length > 0 ? collectionId : randomUUID().toString();
  collection.name = collection.collectionId;
  collection.updatedAt = Clock.currTime();

  if ("name" in request && request["name"].isString) {
    collection.name = request["name"].get!string;
  }
  if ("description" in request && request["description"].isString) {
    collection.description = request["description"].get!string;
  }
  if ("technical_role_ids" in request && request["technical_role_ids"].isArray) {
    collection.technicalRoleIds = stringArrayFromJson(request["technical_role_ids"]);
  }

  return collection;
}