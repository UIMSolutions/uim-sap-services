module uim.sap.buh.models.api;
import uim.sap.buh;

mixin(ShowModule!());

@safe:
struct BUHApi {
  string id;
  string name;
  string provider;
  string apiVersion;
  string visibility = "public";
  string summary;
  string[] tags;
  SysTime createdAt;

  override Json toJson()  {
    Json info = super.toJson;
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

BUHApi apiFromJson(Json payload) {
  BUHApi api;
  api.id = randomUUID().toString();
  api.createdAt = Clock.currTime();

  if ("name" in payload && payload["name"].isString) {
    api.name = payload["name"].get!string;
  }
  if ("provider" in payload && payload["provider"].isString) {
    api.provider = payload["provider"].get!string;
  }
  if ("version" in payload && payload["version"].isString) {
    api.apiVersion = payload["version"].get!string;
  }
  if ("visibility" in payload && payload["visibility"].isString) {
    api.visibility = payload["visibility"].get!string;
  }
  if ("summary" in payload && payload["summary"].isString) {
    api.summary = payload["summary"].get!string;
  }

  if ("tags" in payload && payload["tags"].isArray) {
    foreach (entry; payload["tags"]) {
      if (entry.isString) {
        api.tags ~= entry.get!string;
      }
    }
  }

  return api;
}