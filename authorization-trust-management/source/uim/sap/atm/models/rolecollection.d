module uim.sap.atm.models.rolecollection;

class ATMRoleCollection : SAPTenantObject {
  mixin(SAPObjectTemplate!ATMRoleCollection);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("name" in request && request["name"].isString) {
      collection.name = request["name"].get!string;
    }
    if ("description" in request && request["description"].isString) {
      collection.description = request["description"].get!string;
    }
    if ("technical_role_ids" in request && request["technical_role_ids"].isArray) {
      collection.technicalRoleIds = stringArrayFromJson(request["technical_role_ids"]);
    }

    return true;
  }

  UUID collectionId;
  string name;
  string description;
  string[] technicalRoleIds;
  SysTime updatedAt;

  override Json toJson() {
    Json info = super.toJson;
    Json roleRefs = technicalRoleIds.map!(r => r.toJson).array.toJson).array.toJson;

    payload["tenant_id"] = tenantId;
    payload["collection_id"] = collectionId;
    payload["name"] = name;
    payload["description"] = description;
    payload["technical_role_ids"] = roleRefs;

    return payload;
  }
}

ATMRoleCollection roleCollectionFromJson(UUID tenantId, string collectionId, Json request) {
  ATMRoleCollection collection = new ATMRoleCollection(request);
  
  collection.tenantId = tenantId;
  collection.collectionId = collectionId.length > 0 ? UUID(collectionId) : randomUUID();
  collection.name = collection.collectionId;
  collection.updatedAt = Clock.currTime();

  return collection;
}
