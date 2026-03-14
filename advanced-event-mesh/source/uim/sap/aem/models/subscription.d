/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.models.subscription;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

class AEMSubscription : SAPTenantObject {
  UUID subscriptionId;
  UUID componentId;
  UUID meshId;
  string topic;

  override Json toJson() {
    Json resultJson = super.toJson();
    resultJson["subscription_id"] = subscriptionId.toJson;
    resultJson["component_id"] = componentId.toJson;
    resultJson["mesh_id"] = meshId.toJson;
    resultJson["topic"] = topic;
    return resultJson;
  }
  ///
  unittest {
    AEMSubscription sub = new AEMSubscription();
    sub.tenantId = randomUUID();
    sub.subscriptionId = randomUUID();
    sub.componentId = randomUUID();
    sub.meshId = randomUUID();
    sub.topic = "test-topic";

    Json json = sub.toJson();
    assert(json["tenant_id"].get!string == sub.tenantId.toString());
    assert(json["subscription_id"].get!string == sub.subscriptionId.toString());
    assert(json["component_id"].get!string == sub.componentId.toString());
    assert(json["mesh_id"].get!string == sub.meshId.toString());
    assert(json["topic"].get!string == sub.topic);
  }

}

AEMSubscription subscriptionFromJson(UUID tenantId, string componentId, Json request) {
  AEMSubscription subscription = new AEMSubscription();
  subscription.tenantId = tenantId;
  subscription.subscriptionId = randomUUID();
  subscription.componentId = UUID(componentId);
  subscription.updatedAt = Clock.currTime();

  if ("subscription_id" in request && request["subscription_id"].isString) {
    subscription.subscriptionId = UUID(request["subscription_id"].get!string);
  }
  if ("mesh_id" in request && request["mesh_id"].isString) {
    subscription.meshId = UUID(request["mesh_id"].get!string);
  }
  if ("topic" in request && request["topic"].isString) {
    subscription.topic = request["topic"].get!string;
  }

  return subscription;
}
