module uim.sap.docmgmtintegration.models.models;

import std.algorithm.searching : canFind;
import std.array : appender;
import std.conv : to;
import std.datetime : Clock, SysTime;
import std.string : replace, toLower, endsWith;
import std.uuid : randomUUID;

import vibe.data.json : Json;

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Supported content types for the built-in viewer.
enum string[] VIEWABLE_EXTENSIONS = [
    ".pdf", ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".svg", ".webp"
  ];

/// Document workflow status.
enum DocumentStatus : string {
  draft = "draft",
  checkedOut = "checked_out",
  checkedIn = "checked_in",
  approved = "approved",
  archived = "archived"
}

/// CMIS base object types.
enum CmisObjectType : string {
  document = "cmis:document",
  folder = "cmis:folder"
}

// ---------------------------------------------------------------------------
// Tenant
// ---------------------------------------------------------------------------

/// Represents a tenant in the multi-tenant system.
struct Tenant {
  UUID tenantId;
  string name;
  string description;
  bool active = true;
  SysTime createdAt;
  SysTime modifiedAt;

  override Json toJson()  {
    Json r = Json.emptyObject;
    r["tenant_id"] = tenantId;
    r["name"] = name;
    r["description"] = description;
    r["active"] = active;
    r["created_at"] = createdAt.toISOExtString();
    r["modified_at"] = modifiedAt.toISOExtString();
    return r;
  }
}

Tenant tenantFromJson(Json request) {
  Tenant t;
  t.tenantId = randomUUID().toString();
  t.createdAt = Clock.currTime();
  t.modifiedAt = t.createdAt;
  t.active = true;

  if ("name" in request && request["name"].isString)
    t.name = request["name"].get!string;
  if ("description" in request && request["description"].isString)
    t.description = request["description"].get!string;

  return t;
}

// ---------------------------------------------------------------------------
// Repository (tenant-scoped)
// ---------------------------------------------------------------------------

/// Describes a connected CMIS-compliant repository, scoped to a tenant.
struct Repository {
  string repositoryId;
  UUID tenantId;
  string name;
  string description;
  string vendorName;
  string productName;
  string productVersion;
  string rootFolderId;
  bool cmisCompliant = true;
  bool encryptionEnabled = false;
  SysTime connectedAt;

  override Json toJson()  {
    Json r = Json.emptyObject;
    r["repository_id"] = repositoryId;
    r["tenant_id"] = tenantId;
    r["name"] = name;
    r["description"] = description;
    r["vendor_name"] = vendorName;
    r["product_name"] = productName;
    r["product_version"] = productVersion;
    r["root_folder_id"] = rootFolderId;
    r["cmis_compliant"] = cmisCompliant;
    r["encryption_enabled"] = encryptionEnabled;
    r["connected_at"] = connectedAt.toISOExtString();
    return r;
  }
}

Repository repositoryFromJson(UUID tenantId, Json request) {
  Repository repo;
  repo.repositoryId = randomUUID().toString();
  repo.tenantId = UUID(tenantId);
  repo.connectedAt = Clock.currTime();
  repo.rootFolderId = randomUUID().toString();

  if ("name" in request && request["name"].isString)
    repo.name = request["name"].get!string;
  if ("description" in request && request["description"].isString)
    repo.description = request["description"].get!string;
  if ("vendor_name" in request && request["vendor_name"].isString)
    repo.vendorName = request["vendor_name"].get!string;
  if ("product_name" in request && request["product_name"].isString)
    repo.productName = request["product_name"].get!string;
  if ("product_version" in request && request["product_version"].isString)
    repo.productVersion = request["product_version"].get!string;
  if ("cmis_compliant" in request && request["cmis_compliant"].type == Json.Type.bool_)
    repo.cmisCompliant = request["cmis_compliant"].get!bool;
  if ("encryption_enabled" in request && request["encryption_enabled"].type == Json.Type.bool_)
    repo.encryptionEnabled = request["encryption_enabled"].get!bool;

  return repo;
}

// ---------------------------------------------------------------------------
// Folder (tenant-scoped)
// ---------------------------------------------------------------------------

/// A folder (container) in the document hierarchy, scoped to a tenant.
struct Folder {
  string folderId;
  UUID tenantId;
  string repositoryId;
  string parentFolderId; // empty string = root-level
  string name;
  string description;
  string createdBy;
  SysTime createdAt;
  SysTime modifiedAt;
  Json properties; // custom metadata / properties

  override Json toJson()  {
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
}

Folder folderFromJson(UUID tenantId, string repositoryId, string parentFolderId, Json request) {
  Folder f;
  f.folderId = randomUUID().toString();
  f.tenantId = UUID(tenantId);
  f.repositoryId = repositoryId;
  f.parentFolderId = parentFolderId;
  f.createdAt = Clock.currTime();
  f.modifiedAt = f.createdAt;
  f.properties = Json.emptyObject;
  f.createdBy = "system";

  if ("name" in request && request["name"].isString)
    f.name = request["name"].get!string;
  if ("description" in request && request["description"].isString)
    f.description = request["description"].get!string;
  if ("created_by" in request && request["created_by"].isString)
    f.createdBy = request["created_by"].get!string;
  if ("properties" in request && request["properties"].isObject)
    f.properties = request["properties"];

  return f;
}

// ---------------------------------------------------------------------------
// Document (tenant-scoped)
// ---------------------------------------------------------------------------

/// A document (file) stored in a repository folder, scoped to a tenant.
struct Document {
  string documentId;
  UUID tenantId;
  string repositoryId;
  string folderId;
  string name;
  string description;
  string mimeType;
  long sizeBytes;
  string createdBy;
  string modifiedBy;
  SysTime createdAt;
  SysTime modifiedAt;
  DocumentStatus status = DocumentStatus.draft;
  string checkedOutBy;
  bool encrypted = false;
  Json properties;

  // Version tracking
  int currentVersion = 1;
  string latestVersionId;

  override Json toJson()  {
    Json r = Json.emptyObject;
    r["document_id"] = documentId;
    r["tenant_id"] = tenantId;
    r["repository_id"] = repositoryId;
    r["folder_id"] = folderId;
    r["name"] = name;
    r["description"] = description;
    r["mime_type"] = mimeType;
    r["size_bytes"] = sizeBytes;
    r["created_by"] = createdBy;
    r["modified_by"] = modifiedBy;
    r["created_at"] = createdAt.toISOExtString();
    r["modified_at"] = modifiedAt.toISOExtString();
    r["status"] = cast(string)status;
    r["checked_out_by"] = checkedOutBy;
    r["encrypted"] = encrypted;
    r["properties"] = properties;
    r["current_version"] = currentVersion;
    r["latest_version_id"] = latestVersionId;
    r["object_type"] = "cmis:document";
    return r;
  }
}

Document documentFromJson(UUID tenantId, string repositoryId, string folderId, Json request) {
  Document d;
  d.documentId = randomUUID().toString();
  d.tenantId = UUID(tenantId);
  d.repositoryId = repositoryId;
  d.folderId = folderId;
  d.createdAt = Clock.currTime();
  d.modifiedAt = d.createdAt;
  d.properties = Json.emptyObject;
  d.createdBy = "system";
  d.modifiedBy = "system";
  d.status = DocumentStatus.draft;
  d.currentVersion = 1;
  d.latestVersionId = randomUUID().toString();

  if ("name" in request && request["name"].isString)
    d.name = request["name"].get!string;
  if ("description" in request && request["description"].isString)
    d.description = request["description"].get!string;
  if ("mime_type" in request && request["mime_type"].isString)
    d.mimeType = request["mime_type"].get!string;
  if ("size_bytes" in request && request["size_bytes"].type == Json.Type.int_)
    d.sizeBytes = request["size_bytes"].get!long;
  if ("created_by" in request && request["created_by"].isString)
    d.createdBy = request["created_by"].get!string;
  if ("properties" in request && request["properties"].isObject)
    d.properties = request["properties"];

  d.modifiedBy = d.createdBy;
  return d;
}

// ---------------------------------------------------------------------------
// Document Version
// ---------------------------------------------------------------------------

/// A specific version of a document.
struct DocumentVersion {
  string versionId;
  string documentId;
  UUID tenantId;
  int versionNumber;
  string versionLabel;
  string comment;
  long sizeBytes;
  string mimeType;
  string createdBy;
  SysTime createdAt;
  bool isMajor;
  bool encrypted = false;

  override Json toJson()  {
    Json r = Json.emptyObject;
    r["version_id"] = versionId;
    r["document_id"] = documentId;
    r["tenant_id"] = tenantId;
    r["version_number"] = versionNumber;
    r["version_label"] = versionLabel;
    r["comment"] = comment;
    r["size_bytes"] = sizeBytes;
    r["mime_type"] = mimeType;
    r["created_by"] = createdBy;
    r["created_at"] = createdAt.toISOExtString();
    r["is_major"] = isMajor;
    r["encrypted"] = encrypted;
    return r;
  }
}

DocumentVersion versionFromJson(UUID tenantId, string documentId,
  int versionNumber, Json request) {
  DocumentVersion v;
  v.versionId = randomUUID().toString();
  v.documentId = documentId;
  v.tenantId = UUID(tenantId);
  v.versionNumber = versionNumber;
  v.createdAt = Clock.currTime();
  v.createdBy = "system";
  v.isMajor = false;

  if (versionNumber == 1) {
    v.versionLabel = "1.0";
    v.isMajor = true;
  } else {
    v.versionLabel = "1." ~ to!string(versionNumber - 1);
  }

  if ("comment" in request && request["comment"].isString)
    v.comment = request["comment"].get!string;
  if ("size_bytes" in request && request["size_bytes"].type == Json.Type.int_)
    v.sizeBytes = request["size_bytes"].get!long;
  if ("mime_type" in request && request["mime_type"].isString)
    v.mimeType = request["mime_type"].get!string;
  if ("created_by" in request && request["created_by"].isString)
    v.createdBy = request["created_by"].get!string;
  if ("is_major" in request && request["is_major"].type == Json.Type.bool_) {
    v.isMajor = request["is_major"].get!bool;
    if (v.isMajor) {
      v.versionLabel = to!string(versionNumber) ~ ".0";
    }
  }
  if ("version_label" in request && request["version_label"].isString)
    v.versionLabel = request["version_label"].get!string;

  return v;
}

// ---------------------------------------------------------------------------
// Breadcrumb
// ---------------------------------------------------------------------------

struct Breadcrumb {
  string folderId;
  string name;

  override Json toJson()  {
    Json r = Json.emptyObject;
    r["folder_id"] = folderId;
    r["name"] = name;
    return r;
  }
}

// ---------------------------------------------------------------------------
// UI Component Configuration
// ---------------------------------------------------------------------------

/// Configuration for the embeddable UI5-based reusable document management component.
struct UIComponentConfig {
  UUID tenantId;
  UUID repositoryId;
  UUID rootFolderId;
  string componentName = "uim.sap.docmgmt.ReusableComponent";
  string componentVersion = "1.0.0";
  string theme = "sap_horizon";
  bool showBreadcrumbs = true;
  bool showVersionHistory = true;
  bool allowUpload = true;
  bool allowDelete = true;
  bool allowMove = true;
  bool allowCopy = true;
  bool showMetadata = true;
  bool showStatusManagement = true;
  int maxUploadSizeMB = 100;
  string locale = "en";

  override Json toJson()  {
    Json r = Json.emptyObject;
    r["tenant_id"] = tenantId;
    r["repository_id"] = repositoryId;
    r["root_folder_id"] = rootFolderId;
    r["component_name"] = componentName;
    r["component_version"] = componentVersion;
    r["theme"] = theme;
    r["show_breadcrumbs"] = showBreadcrumbs;
    r["show_version_history"] = showVersionHistory;
    r["allow_upload"] = allowUpload;
    r["allow_delete"] = allowDelete;
    r["allow_move"] = allowMove;
    r["allow_copy"] = allowCopy;
    r["show_metadata"] = showMetadata;
    r["show_status_management"] = showStatusManagement;
    r["max_upload_size_mb"] = maxUploadSizeMB;
    r["locale"] = locale;
    return r;
  }
}

UIComponentConfig uiConfigFromJson(UUID tenantId, Json request) {
  UIComponentConfig cfg;
  cfg.tenantId = UUID(tenantId);

  if ("repository_id" in request && request["repository_id"].isString)
    cfg.repositoryId = request["repository_id"].get!string;
  if ("root_folder_id" in request && request["root_folder_id"].isString)
    cfg.rootFolderId = request["root_folder_id"].get!string;
  if ("theme" in request && request["theme"].isString)
    cfg.theme = request["theme"].get!string;
  if ("locale" in request && request["locale"].isString)
    cfg.locale = request["locale"].get!string;
  if ("show_breadcrumbs" in request && request["show_breadcrumbs"].type == Json.Type.bool_)
    cfg.showBreadcrumbs = request["show_breadcrumbs"].get!bool;
  if ("show_version_history" in request && request["show_version_history"].type == Json.Type.bool_)
    cfg.showVersionHistory = request["show_version_history"].get!bool;
  if ("allow_upload" in request && request["allow_upload"].type == Json.Type.bool_)
    cfg.allowUpload = request["allow_upload"].get!bool;
  if ("allow_delete" in request && request["allow_delete"].type == Json.Type.bool_)
    cfg.allowDelete = request["allow_delete"].get!bool;
  if ("allow_move" in request && request["allow_move"].type == Json.Type.bool_)
    cfg.allowMove = request["allow_move"].get!bool;
  if ("allow_copy" in request && request["allow_copy"].type == Json.Type.bool_)
    cfg.allowCopy = request["allow_copy"].get!bool;
  if ("show_metadata" in request && request["show_metadata"].type == Json.Type.bool_)
    cfg.showMetadata = request["show_metadata"].get!bool;
  if ("show_status_management" in request && request["show_status_management"].type == Json
    .Type.bool_)
    cfg.showStatusManagement = request["show_status_management"].get!bool;
  if ("max_upload_size_mb" in request && request["max_upload_size_mb"].type == Json.Type.int_)
    cfg.maxUploadSizeMB = cast(int)request["max_upload_size_mb"].get!long;

  return cfg;
}

// ---------------------------------------------------------------------------
// Integration Link
// ---------------------------------------------------------------------------

/// Links business objects from external applications to documents in the
/// document management system, enabling embedded document scenarios.
struct IntegrationLink {
  UUID linkId;
  UUID tenantId;
  UUID externalObjectId; // ID of the business object in the calling app
  string externalObjectType; // e.g. "SalesOrder", "PurchaseOrder", etc.
  UUID documentId; // linked document in this service
  UUID repositoryId;
  string description;
  SysTime createdAt;
  string createdBy;

  override Json toJson()  {
    Json r = Json.emptyObject;
    r["link_id"] = linkId;
    r["tenant_id"] = tenantId;
    r["external_object_id"] = externalObjectId;
    r["external_object_type"] = externalObjectType;
    r["document_id"] = documentId;
    r["repository_id"] = repositoryId;
    r["description"] = description;
    r["created_at"] = createdAt.toISOExtString();
    r["created_by"] = createdBy;
    return r;
  }
}

IntegrationLink linkFromJson(UUID tenantId, Json request) {
  IntegrationLink lnk;
  lnk.linkId = randomUUID().toString();
  lnk.tenantId = UUID(tenantId);
  lnk.createdAt = Clock.currTime();
  lnk.createdBy = "system";

  if ("external_object_id" in request && request["external_object_id"].isString)
    lnk.externalObjectId = request["external_object_id"].get!string;
  if ("external_object_type" in request && request["external_object_type"].isString)
    lnk.externalObjectType = request["external_object_type"].get!string;
  if ("document_id" in request && request["document_id"].isString)
    lnk.documentId = request["document_id"].get!string;
  if ("repository_id" in request && request["repository_id"].isString)
    lnk.repositoryId = request["repository_id"].get!string;
  if ("description" in request && request["description"].isString)
    lnk.description = request["description"].get!string;
  if ("created_by" in request && request["created_by"].isString)
    lnk.createdBy = request["created_by"].get!string;

  return lnk;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Check if a file extension is supported by the built-in viewer.
bool isViewableExtension(string fileName) {
  auto lower = toLower(fileName);
  foreach (ext; VIEWABLE_EXTENSIONS) {
    if (lower.endsWith(ext))
      return true;
  }
  return false;
}

/// Escape a value for CSV output.
string escapeCsv(string value) {
  auto escaped = value.replace("\"", "\"\"");
  return "\"" ~ escaped ~ "\"";
}
