module uim.sap.atm.models.rolecollection;

class ATMRoleCollection : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!ATMRoleCollection);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("name" in request && request["name"].isString) {
      collection.name = request["name"].getString;
    }
    if ("description" in request && request["description"].isString) {
      collection.description = request["description"].getString;
    }
    if ("technical_role_ids" in request && request["technical_role_ids"].isArray) {
      collection.technicalRoleIds = stringArrayFromJson(request["technical_role_ids"]);
    }

    return true;
  }

  UUID collectionId;
  string name;
  string description;
  UUID[] technicalRoleIds;
  SysTime updatedAt;

  override Json toJson() {
    Json roleRefs = technicalRoleIds.map!(r => r.toJson).array.toJson).array.toJson;
    
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("collection_id", collectionId)
      .set("name", name)
      .set("description", description)
      .set("technical_role_ids", roleRefs);
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
