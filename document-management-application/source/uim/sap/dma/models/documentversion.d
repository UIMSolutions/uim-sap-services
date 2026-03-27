module uim.sap.dma.models.documentversion;

/// A specific version of a document.
class DMADocumentVersion : SAPTenantObject {
  mixin(SAPObjectTemplate!DMADocumentVersion);
  
  UUID versionId;
  UUID documentId;
  int versionNumber;
  string versionLabel; // e.g. "1.0", "1.1", "2.0"
  string comment;
  long sizeBytes;
  string mimeType;
  string createdBy;
  SysTime createdAt;
  bool isMajor; // major vs minor version
  bool encrypted = false;

  override Json toJson() {
    return super.toJson()
      .set("version_id", versionId)
      .set("document_id", documentId)
      .set("version_number", versionNumber)
      .set("version_label", versionLabel)
      .set("comment", comment)
      .set("size_bytes", sizeBytes)
      .set("mime_type", mimeType)
      .set("created_by", createdBy)
      .set("is_major", isMajor)
      .set("encrypted", encrypted);
  }

  DMADocumentVersion versionFromJson(UUID documentId, int versionNumber, Json request) {
    DMADocumentVersion v = new DMADocumentVersion();
    v.versionId = randomUUID();
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