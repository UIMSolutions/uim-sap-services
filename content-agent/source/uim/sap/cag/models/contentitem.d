module uim.sap.cag.models.contentitem;

class CAGContentItem : SAPTenantObject {
  mixin(SAPObjectTemplate!CAGContentItem);

  UUID contentId;
  string title;
  string contentType;
  string contentVersion;
  UUID providerId;
  string[] dependencies;
  string[] relatedContent;
  Json metadata;

  override Json toJson() {
    auto deps = dependencies.map!(dep => dep).array; // Convert string[] to Json array

    auto related = relatedContent.map!(cont => cont).array; // Convert string[] to Json array

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("content_id", contentId)
      .set("title", title)
      .set("content_type", contentType)
      .set("version", contentVersion)
      .set("provider_id", providerId)
      .set("dependencies", deps)
      .set("related_content", related)
      .set("metadata", metadata);
  }
}
