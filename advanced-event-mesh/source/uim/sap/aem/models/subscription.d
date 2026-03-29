/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.models.subscription;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

/**
  * Represents a subscription to an event topic in the Advanced Event Mesh.
  * Each subscription is associated with a specific component and mesh, and belongs to a tenant.
  *
  * The subscription includes:
  * - subscriptionId: Unique identifier for the subscription.
  * - componentId: Identifier of the component that owns the subscription.
  * - meshId: Identifier of the mesh to which the subscription belongs.
  * - topic: The event topic to which the subscription is subscribed.
  * The subscription can be serialized to JSON for storage or transmission, and can be created from JSON input.
  */
class AEMSubscription : SAPTenantEntity {
  mixin(SAPTenantEntity!AEMSubscription);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("subscription_id" in request && request["subscription_id"].isString) {
      subscriptionId = UUID(request["subscription_id"].get!string);
    }
    if ("component_id" in request && request["component_id"].isString) {
      componentId = UUID(request["component_id"].get!string);
    }
    if ("mesh_id" in request && request["mesh_id"].isString) {
      meshId = UUID(request["mesh_id"].get!string);
    }
    if ("topic" in request && request["topic"].isString) {
      topic = request["topic"].getString;
    }

    subscriptionId = "subscription_id" in request ? UUID(request["subscription_id"].get!string) : randomUUID();

    componentId = "component_id" in request ? UUID(request["component_id"].get!string) : UUID(
      componentId);
    updatedAt = "updated_at" in request ? Clock.currTime(
      request["updated_at"].get!string) : Clock.currTime();

    return true;
  }

  UUID subscriptionId;
  UUID componentId;
  UUID meshId;
  string topic;

  override Json toJson() {
    return super.toJson()
      .set("subscription_id", subscriptionId.toJson)
      .set("component_id", componentId.toJson)
      .set("mesh_id", meshId.toJson)
      .set("topic", topic);
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

  AEMSubscription opCall(UUID tenantId, string componentId, Json request) {
    AEMSubscription subscription = new AEMSubscription(request);
    subscription.tenantId = tenantId;

    return subscription;
  }
}
