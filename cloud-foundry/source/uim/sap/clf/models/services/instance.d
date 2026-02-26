module uim.sap.clf.models.services.instance;

import uim.sap.clf;

mixin(ShowModule!());

@safe:
struct CLFServiceInstance {
  string guid;
  string name;
  string serviceGuid;
  string spaceGuid;
  string status = "create succeeded";
  SysTime createdAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["guid"] = guid;
    payload["name"] = name;
    payload["service_guid"] = serviceGuid;
    payload["space_guid"] = spaceGuid;
    payload["status"] = status;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}

CLFServiceInstance serviceInstanceFromJson(Json payload) {
  CLFServiceInstance instance;
  instance.guid = randomUUID().toString();
  instance.createdAt = Clock.currTime();
  if ("name" in payload && payload["name"].type == Json.Type.string) {
    instance.name = payload["name"].get!string;
  }
  if ("service_guid" in payload && payload["service_guid"].type == Json.Type.string) {
    instance.serviceGuid = payload["service_guid"].get!string;
  }
  if ("space_guid" in payload && payload["space_guid"].type == Json.Type.string) {
    instance.spaceGuid = payload["space_guid"].get!string;
  }
  return instance;
}
