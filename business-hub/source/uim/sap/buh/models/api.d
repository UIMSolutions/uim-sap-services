module uim.sap.buh.models.api;

struct BUHApi {
  string id;
  string name;
  string provider;
  string apiVersion;
  string visibility = "public";
  string summary;
  string[] tags;
  SysTime createdAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    Json tagsJson = Json.emptyArray;
    foreach (tag; tags) {
      tagsJson ~= Json(tag);
    }

    payload["id"] = id;
    payload["name"] = name;
    payload["provider"] = provider;
    payload["version"] = apiVersion;
    payload["visibility"] = visibility;
    payload["summary"] = summary;
    payload["tags"] = tagsJson;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}
