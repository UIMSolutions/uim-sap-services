module uim.sap.buh.models.product;
import uim.sap.buh;

mixin(ShowModule!());

@safe:
struct BUHProduct {
  string id;
  string name;
  string description;
  string[] apiIds;
  SysTime createdAt;

  override Json toJson()  {
    Json info = super.toJson;
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

BUHProduct productFromJson(Json payload) {
  BUHProduct product;
  product.id = randomUUID().toString();
  product.createdAt = Clock.currTime();

  if ("name" in payload && payload["name"].isString) {
    product.name = payload["name"].get!string;
  }
  if ("description" in payload && payload["description"].isString) {
    product.description = payload["description"].get!string;
  }
  if ("api_ids" in payload && payload["api_ids"].isArray) {
    foreach (entry; payload["api_ids"]) {
      if (entry.isString) {
        product.apiIds ~= entry.get!string;
      }
    }
  }

  return product;
}
