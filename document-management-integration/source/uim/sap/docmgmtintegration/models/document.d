module uim.sap.docmgmtintegration.models.document;

// ---------------------------------------------------------------------------
// Document (tenant-scoped)
// ---------------------------------------------------------------------------

/// A document (file) stored in a repository folder, scoped to a tenant.
class Document : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!Document);

  UUID documentId;
  UUID repositoryId;
  UUID folderId;
  string name;
  string description;
  string mimeType;
  long sizeBytes;
  string createdBy;
  string modifiedBy;
  SysTime modifiedAt;
  DocumentStatus status = DocumentStatus.draft;
  string checkedOutBy;
  bool encrypted = false;
  Json properties;

  // Version tracking
  int currentVersion = 1;
  string latestVersionId;

  override Json toJson() {
    return super.toJson
      .set("document_id", documentId)
      .set("tenant_id", tenantId)
      .set("repository_id", repositoryId)
      .set("folder_id", folderId)
      .set("name", name)
      .set("description", description)
      .set("mime_type", mimeType)
      .set("size_bytes", sizeBytes)
      .set("created_by", createdBy)
      .set("modified_by", modifiedBy)
      .set("created_at", createdAt.toISOExtString())
      .set("modified_at", modifiedAt.toISOExtString())
      .set("status", cast(string)status)
      .set("checked_out_by", checkedOutBy)
      .set("encrypted", encrypted)
      .set("properties", properties)
      .set("current_version", currentVersion)
      .set("latest_version_id", latestVersionId)
      .set("object_type", "cmis:document");
  }

  Document documentFromJson(UUID tenantId, string repositoryId, string folderId, Json request) {
    Document d = new Document();
    d.documentId = randomUUID();
    d.tenantId = tenantId;
    d.repositoryId = repositoryId;
    d.folderId = folderId;
    d.createdAt = Clock.currTime();
    d.modifiedAt = d.createdAt;
    d.properties = Json.emptyObject;
    d.createdBy = "system";
    d.modifiedBy = "system";
    d.status = DocumentStatus.draft;
    d.currentVersion = 1;
    d.latestVersionId = randomUUID();

    if ("name" in request && request["name"].isString)
      d.name = request["name"].getString;
    if ("description" in request && request["description"].isString)
      d.description = request["description"].getString;
    if ("mime_type" in request && request["mime_type"].isString)
      d.mimeType = request["mime_type"].getString;
    if ("size_bytes" in request && request["size_bytes"].isInteger)
      d.sizeBytes = request["size_bytes"].get!long;
    if ("created_by" in request && request["created_by"].isString)
      d.createdBy = request["created_by"].getString;
    if ("properties" in request && request["properties"].isObject)
      d.properties = request["properties"];

    d.modifiedBy = d.createdBy;
    return d;
  }
}