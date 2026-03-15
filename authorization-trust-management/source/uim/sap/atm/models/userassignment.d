module uim.sap.atm.models.userassignment;

struct ATMUserAssignment {
  UUID tenantId;
  UUID userId;
  UUID idpId;
  string[] roleCollectionIds;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    Json refs = Json.emptyArray;
    foreach (roleCollectionId; roleCollectionIds) {
      refs ~= roleCollectionId;
    }

    payload["tenant_id"] = tenantId;
    payload["user_id"] = userId;
    payload["idp_id"] = idpId;
    payload["role_collection_ids"] = refs;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

ATMUserAssignment userAssignmentFromJson(string tenantId, string userId, Json request) {
  ATMUserAssignment assignment;
  assignment.tenantId = UUID(tenantId);
  assignment.userId = userId;
  assignment.updatedAt = Clock.currTime();

  if ("idp_id" in request && request["idp_id"].isString) {
    assignment.idpId = request["idp_id"].get!string;
  }
  if ("role_collection_ids" in request && request["role_collection_ids"].isArray) {
    assignment.roleCollectionIds = stringArrayFromJson(request["role_collection_ids"]);
  }

  return assignment;
}
