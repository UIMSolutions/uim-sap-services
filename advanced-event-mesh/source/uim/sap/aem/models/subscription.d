/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.models.subscription;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

struct AEMSubscription {
    string tenantId;
    string subscriptionId;
    string componentId;
    string meshId;
    string topic;
    SysTime updatedAt;

    Json toJson() const {
        Json resultJson = Json.emptyObject;
        resultJson["tenant_id"] = tenantId;
        resultJson["subscription_id"] = subscriptionId;
        resultJson["component_id"] = componentId;
        resultJson["mesh_id"] = meshId;
        resultJson["topic"] = topic;
        resultJson["updated_at"] = updatedAt.toISOExtString();
        return resultJson;
    }
}

AEMSubscription subscriptionFromJson(string tenantId, string componentId, Json request) {
  AEMSubscription subscription;
  subscription.tenantId = tenantId;
  subscription.subscriptionId = randomUUID().toString();
  subscription.componentId = componentId;
  subscription.updatedAt = Clock.currTime();

  if ("subscription_id" in request && request["subscription_id"].isString) {
    subscription.subscriptionId = request["subscription_id"].get!string;
  }
  if ("mesh_id" in request && request["mesh_id"].isString) {
    subscription.meshId = request["mesh_id"].get!string;
  }
  if ("topic" in request && request["topic"].isString) {
    subscription.topic = request["topic"].get!string;
  }

  return subscription;
}
