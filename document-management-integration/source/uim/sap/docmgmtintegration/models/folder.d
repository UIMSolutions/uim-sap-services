module uim.sap.docmgmtintegration.models.folder;

// ---------------------------------------------------------------------------
// Folder (tenant-scoped)
// ---------------------------------------------------------------------------

/// A folder (container) in the document hierarchy, scoped to a tenant.
class Folder : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!Folder);

  UUID folderId;
  UUID repositoryId;
  UUID parentFolderId; // empty string = root-level
  string name;
  string description;
  string createdBy;
  SysTime createdAt;
  SysTime modifiedAt;
  Json properties; // custom metadata / properties

  override Json toJson() {
    Json r = Json.emptyObject;
    r["folder_id"] = folderId;
    r["tenant_id"] = tenantId;
    r["repository_id"] = repositoryId;
    r["parent_folder_id"] = parentFolderId;
    r["name"] = name;
    r["description"] = description;
    r["created_by"] = createdBy;
    r["created_at"] = createdAt.toISOExtString();
    r["modified_at"] = modifiedAt.toISOExtString();
    r["properties"] = properties;
    r["object_type"] = "cmis:folder";
    return r;
  }

  string pathSegment() const {
    return name;
  }

  Folder folderFromJson(UUID tenantId, string repositoryId, string parentFolderId, Json request) {
    Folder f;
    f.folderId = randomUUID();
    f.tenantId = tenantId;
    f.repositoryId = repositoryId;
    f.parentFolderId = parentFolderId;
    f.createdAt = Clock.currTime();
    f.modifiedAt = f.createdAt;
    f.properties = Json.emptyObject;
    f.createdBy = "system";

    if ("name" in request && request["name"].isString)
      f.name = request["name"].getString;
    if ("description" in request && request["description"].isString)
      f.description = request["description"].getString;
    if ("created_by" in request && request["created_by"].isString)
      f.createdBy = request["created_by"].getString;
    if ("properties" in request && request["properties"].isObject)
      f.properties = request["properties"];

    return f;
  }
}