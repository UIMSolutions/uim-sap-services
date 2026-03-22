module uim.sap.cag.models.contentitem;

struct CAGContentItem {
  UUID tenantId;
  string contentId;
  string title;
  string contentType;
  string contentVersion;
  string providerId;
  string[] dependencies;
  string[] relatedContent;
  Json metadata;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["content_id"] = contentId;
    payload["title"] = title;
    payload["content_type"] = contentType;
    payload["version"] = contentVersion;
    payload["provider_id"] = providerId;

    Json deps = Json.emptyArray;
    foreach (value; dependencies)
      deps ~= value;
    payload["dependencies"] = deps;

    Json related = Json.emptyArray;
    foreach (value; relatedContent)
      related ~= value;
    payload["related_content"] = related;

    payload["metadata"] = metadata;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}