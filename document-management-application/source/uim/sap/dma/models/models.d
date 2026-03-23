module uim.sap.documentmanagement.models.models;

import std.algorithm.searching : canFind;
import std.array : appender;
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
// Repository
// ---------------------------------------------------------------------------




// ---------------------------------------------------------------------------
// Folder
// ---------------------------------------------------------------------------

/// A folder (container) in the document hierarchy.
struct Folder {
  string folderId;
  string repositoryId;
  string parentFolderId; // empty string = root-level
  string name;
  string description;
  string createdBy;
  SysTime createdAt;
  SysTime modifiedAt;
  Json properties; // custom metadata / properties

  override Json toJson()  {
    return super.toJson()
    .set("folder_id", folderId)
    .set("repository_id", repositoryId)
    .set("parent_folder_id", parentFolderId)
    .set("name", name)
    .set("description", description)
    .set("created_by", createdBy)
    .set("created_at", createdAt.toISOExtString())
    .set("modified_at", modifiedAt.toISOExtString())
    .set("properties", properties)
    .set("object_type", "cmis:folder");
  }

  /// Build a breadcrumb-compatible path segment identifier.
  string pathSegment() const {
    return name;
  }
}

Folder folderFromJson(string repositoryId, string parentFolderId, Json request) {
  Folder f;
  f.folderId = randomUUID().toString();
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
// Document
// ---------------------------------------------------------------------------

/// A document (file) stored in a repository folder.
struct Document {
  string documentId;
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
  Json properties; // custom metadata

  // Version tracking
  int currentVersion = 1;
  string latestVersionId;

  override Json toJson()  {
    Json r = Json.emptyObject;
    r["document_id"] = documentId;
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

Document documentFromJson(string repositoryId, string folderId, Json request) {
  Document d;
  d.documentId = randomUUID().toString();
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
  if ("size_bytes" in request && request["size_bytes"].isInteger)
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
  int versionNumber;
  string versionLabel; // e.g. "1.0", "1.1", "2.0"
  string comment;
  long sizeBytes;
  string mimeType;
  string createdBy;
  SysTime createdAt;
  bool isMajor; // major vs minor version
  bool encrypted = false;

  override Json toJson()  {
    Json r = Json.emptyObject;
    r["version_id"] = versionId;
    r["document_id"] = documentId;
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

DocumentVersion versionFromJson(string documentId, int versionNumber, Json request) {
  DocumentVersion v;
  v.versionId = randomUUID().toString();
  v.documentId = documentId;
  v.versionNumber = versionNumber;
  v.createdAt = Clock.currTime();
  v.createdBy = "system";
  v.isMajor = false;

  import std.conv : to;

  if (versionNumber == 1) {
    v.versionLabel = "1.0";
    v.isMajor = true;
  } else {
    v.versionLabel = "1." ~ to!string(versionNumber - 1);
  }

  if ("comment" in request && request["comment"].isString)
    v.comment = request["comment"].get!string;
  if ("size_bytes" in request && request["size_bytes"].isInteger)
    v.sizeBytes = request["size_bytes"].get!long;
  if ("mime_type" in request && request["mime_type"].isString)
    v.mimeType = request["mime_type"].get!string;
  if ("created_by" in request && request["created_by"].isString)
    v.createdBy = request["created_by"].get!string;
  if ("is_major" in request && request["is_major"].isBoolean) {
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

/// A single step in a breadcrumb path.
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
// Helpers
// ---------------------------------------------------------------------------

/// Check if a file extension is supported by the built-in viewer.
bool isViewableExtension(string fileName) {
  auto lower = toLower(fileName);
  foreach (ext; VIEWABLE_EXTENSIONS) {
    if (lower.endsWith(ext)) {
      return true;
    }
  }
  return false;
}

/// Escape a value for CSV output.
string escapeCsv(string value) {
  auto escaped = value.replace("\"", "\"\"");
  return "\"" ~ escaped ~ "\"";
}
