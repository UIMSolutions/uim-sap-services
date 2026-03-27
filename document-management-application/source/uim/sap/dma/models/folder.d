module uim.sap.dma.models.folder;

import uim.sap.dma;

mixin(ShowModule!());

@safe:

/// A folder (container) in the document hierarchy.
class DMAFolder : SAPObject {
  mixin(SAPObjectTemplate!DMAFolder);

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
    return super.toJson()
      .set("folder_id", folderId)
      .set("repository_id", repositoryId)
      .set("parent_folder_id", parentFolderId)
      .set("name", name)
      .set("description", description)
      .set("created_by", createdBy)
      .set("modified_at", modifiedAt.toISOExtString())
      .set("properties", properties)
      .set("object_type", "cmis:folder");
  }

  /// Build a breadcrumb-compatible path segment identifier.
  string pathSegment() const {
    return name;
  }

  static DMAFolder folderFromJson(string repositoryId, string parentFolderId, Json request) {
    DMAFolder f = new DMAFolder(request);
    f.folderId = randomUUID();
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