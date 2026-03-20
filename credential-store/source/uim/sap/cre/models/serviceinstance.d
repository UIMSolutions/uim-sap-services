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

  override Json toJson() {
    return super.toJson
      .set("instance_id", instanceId)
      .set("service_id", serviceId)
      .set("plan_id", planId)
      .set("status", status)
      .set("parameters", parameters);
  }

  CREServiceInstance opCall(UUID instanceId, Json request) {
    CREServiceInstance instance = new CREServiceInstance(request);
    instance.instanceId = instanceId;
    instance.createdAt = Clock.currTime();
    instance.updatedAt = instance.createdAt;

    if ("service_id" in request && request["service_id"].isString) {
      instance.serviceId = UUID(request["service_id"].get!string);
    }
    if ("plan_id" in request && request["plan_id"].isString) {
      instance.planId = UUID(request["plan_id"].get!string);
    }
    
    instance.parameters = "parameters" in request && request["parameters"].isObject 
      ? request["parameters"] 
      : Json.emptyObject;
      
    return instance;
  }
}
