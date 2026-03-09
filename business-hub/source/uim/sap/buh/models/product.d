module uim.sap.buh.models.product;

struct BUHProduct {
  string id;
  string name;
  string description;
  string[] apiIds;
  SysTime createdAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    Json apiIdsJson = Json.emptyArray;
    foreach (apiId; apiIds) {
      apiIdsJson ~= Json(apiId);
    }

    payload["id"] = id;
    payload["name"] = name;
    payload["description"] = description;
    payload["api_ids"] = apiIdsJson;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}
