module uim.sap.ctm.models.contentitem;

// ---------------------------------------------------------------------------
// CTMContentItem – a content attachment on a transport request
// ---------------------------------------------------------------------------
struct CTMContentItem {
  UUID contentId;
  UUID requestId;
  /// Type: "mta" | "iflow" | "abap-transport" | "destination-config" | "role" | "other"
  string contentType;
  string name;
  string version_;
  string description;
  /// Opaque reference (file path, archive URL, etc.)
  string reference;
  SysTime attachedAt;

  override Json toJson() {
    return super.toJson()
      .set("content_id", contentId)
      .set("request_id", requestId)
      .set("content_type", contentType)
      .set("name", name)
      .set("version", version_)
      .set("description", description)
      .set("reference", reference)
      .set("attached_at", attachedAt.toISOExtString());
  }
}
