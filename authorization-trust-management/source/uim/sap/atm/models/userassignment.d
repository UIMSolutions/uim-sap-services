module uim.sap.atm.models.userassignment;

class ATMUserAssignment : SAPTenantObject {
  mixin(SAPObjectTemplate!ATMUserAssignment);

  UUID userId;
  UUID idpId;
  string[] roleCollectionIds;

  override Json toJson() {
    Json refs = roleCollectionIds.map!(id => id).array.toJson;

    return super.toJson()
      .set("user_id", userId)
      .set("idp_id", idpId)
      .set("role_collection_ids", refs);
  }

  static ATMUserAssignment opCall(string tenantId, string userId, Json request) {
    ATMUserAssignment assignment = new ATMUserAssignment(request);
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
}
