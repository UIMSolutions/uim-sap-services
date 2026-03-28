module uim.sap.docmgmtintegration.models.documentversion;

// ---------------------------------------------------------------------------
// Document Version
// ---------------------------------------------------------------------------

/// A specific version of a document.
struct DocumentVersion {
  UUID versionId;
  UUID documentId;
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

  override Json toJson() {
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

  DocumentVersion versionFromJson(UUID tenantId, string documentId,
  int versionNumber, Json request) {
  DocumentVersion v;
  v.versionId = randomUUID();
  v.documentId = documentId;
  v.tenantId = tenantId;
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
    v.comment = request["comment"].getString;
  if ("size_bytes" in request && request["size_bytes"].isInteger)
    v.sizeBytes = request["size_bytes"].get!long;
  if ("mime_type" in request && request["mime_type"].isString)
    v.mimeType = request["mime_type"].getString;
  if ("created_by" in request && request["created_by"].isString)
    v.createdBy = request["created_by"].getString;
  if ("is_major" in request && request["is_major"].isBoolean) {
    v.isMajor = request["is_major"].get!bool;
    if (v.isMajor) {
      v.versionLabel = to!string(versionNumber) ~ ".0";
    }
  }
  if ("version_label" in request && request["version_label"].isString)
    v.versionLabel = request["version_label"].getString;

  return v;
}
}