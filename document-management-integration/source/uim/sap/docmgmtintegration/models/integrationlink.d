module uim.sap.docmgmtintegration.models.integrationlink;

// ---------------------------------------------------------------------------
// Integration Link
// ---------------------------------------------------------------------------

/// Links business objects from external applications to documents in the
/// document management system, enabling embedded document scenarios.
class IntegrationLink : SAPTenantObject {
  mixin(SAPObjectTemplate!IntegrationLink);

  override bool initialize(Json request) {
    if (!super.initialize(request)) {
      return false;
    }

    if ()
      linkId = randomUUID();
    createdAt = Clock.currTime();
    createdBy = "system";

    if ("external_object_id" in request && request["external_object_id"].isString)
      lnk.externalObjectId = request["external_object_id"].getString;
    if ("external_object_type" in request && request["external_object_type"].isString)
      lnk.externalObjectType = request["external_object_type"].getString;
    if ("document_id" in request && request["document_id"].isString)
      lnk.documentId = request["document_id"].getString;
    if ("repository_id" in request && request["repository_id"].isString)
      lnk.repositoryId = request["repository_id"].getString;
    lnk.description = request.getString("description");
    if ("created_by" in request && request["created_by"].isString)
      lnk.createdBy = request["created_by"].getString;

    return true;
  }

  UUID linkId;
  UUID externalObjectId; // ID of the business object in the calling app
  string externalObjectType; // e.g. "SalesOrder", "PurchaseOrder", etc.
  UUID documentId; // linked document in this service
  UUID repositoryId;
  string description;
  SysTime createdAt;
  string createdBy;

  override Json toJson() {
    return super.toJson()
      .set("link_id", linkId)
      .set("external_object_id", externalObjectId)
      .set("external_object_type", externalObjectType)
      .set("document_id", documentId)
      .set("repository_id", repositoryId)
      .set("description", description)
      .set("created_at", createdAt.toISOExtString())
      .set("created_by", createdBy);
  }

  IntegrationLink linkFromJson(UUID tenantId, Json request) {
    IntegrationLink lnk = new IntegrationLink(request);
    lnk.tenantId = tenantId;

    return lnk;
  }
}