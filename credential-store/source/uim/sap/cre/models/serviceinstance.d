module uim.sap.cre.models.serviceinstance;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

class CREServiceInstance : SAPObject {
  mixin(SAPObjectTemplate!CREServiceInstance);

  UUID instanceId;
  UUID serviceId;
  UUID planId;
  string status = "created";
  Json parameters;

  override Json toJson()  {
    return super.toJson
    .set("instance_id", instanceId);
    .set("service_id", serviceId);
    .set("plan_id", planId);
    .set("status", status);
    .set("parameters", parameters);
    return payload;
  }

  CREServiceInstance opCall(string instanceId, Json request) {
  CREServiceInstance instance = new CREServiceInstance(request);
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
}


