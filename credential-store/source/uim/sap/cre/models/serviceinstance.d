module uim.sap.cre.models.serviceinstance;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

class CREServiceInstance : SAPEntity {
  mixin(SAPEntityTemplate!CREServiceInstance);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("instance_id" in initData && initData["instance_id"].isString) {
      instanceId = UUID(initData["instance_id"].get!string);
    }

    if ("service_id" in initData && initData["service_id"].isString) {
      serviceId = UUID(initData["service_id"].get!string);
    }

    if ("plan_id" in initData && initData["plan_id"].isString) {
      planId = UUID(initData["plan_id"].get!string);
    }

    status = initData.getString("status", "created");
    return true;
  }

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

  static CREServiceInstance opCall(UUID instanceId, Json request) {
    CREServiceInstance instance = new CREServiceInstance(request);
    instance.instanceId = instanceId;
    instance.createdAt = Clock.currTime();
    instance.updatedAt = instance.createdAt;
    instance.parameters = request.getObject("parameters", Json.emptyObject);

    return instance;
  }
}
