module uim.sap.cre.models.serviceinstance;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

struct CREServiceInstance {
  string instanceId;
  string serviceId;
  string planId;
  string status = "created";
  Json parameters;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["instance_id"] = instanceId;
    payload["service_id"] = serviceId;
    payload["plan_id"] = planId;
    payload["status"] = status;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    payload["parameters"] = parameters;
    return payload;
  }
}


CREServiceInstance instanceFromJson(string instanceId, Json request) {
  CREServiceInstance instance;
  instance.instanceId = instanceId;
  instance.createdAt = Clock.currTime();
  instance.updatedAt = instance.createdAt;

  if ("service_id" in request && request["service_id"].isString) {
    instance.serviceId = request["service_id"].get!string;
  }
  if ("plan_id" in request && request["plan_id"].isString) {
    instance.planId = request["plan_id"].get!string;
  }
  if ("parameters" in request && request["parameters"].isObject) {
    instance.parameters = request["parameters"];
  } else {
    instance.parameters = Json.emptyObject;
  }
  return instance;
}