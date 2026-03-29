/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.models.brokerservice;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

class AEMBrokerService : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!AEMBrokerService);

  UUID brokerServiceId;
  string name;
  string plan;
  string region;
  string status = "running";

  long connectedClients;
  long eventsPublished;

  override override Json toJson()  {
    return super.toJson()
    .set("broker_service_id", brokerServiceId.toString())
    .set("name", name)
    .set("plan", plan)
    .set("region", region)
    .set("status", status)
    .set("connected_clients", connectedClients)
    .set("events_published", eventsPublished);
  }

  static AEMBrokerService opCall(UUID tenantId, Json request, string defaultRegion) {
    AEMBrokerService broker = new AEMBrokerService();
    broker.tenantId = tenantId;
    broker.brokerServiceId = randomUUID();
    broker.plan = "standard";
    broker.region = defaultRegion;
    broker.createdAt = Clock.currTime();
    broker.updatedAt = broker.createdAt;

    if ("broker_service_id" in request && request["broker_service_id"].isString) {
        broker.brokerServiceId = request["broker_service_id"].getString;
    }
    if ("name" in request && request["name"].isString) {
        broker.name = request["name"].getString;
    }
    if ("plan" in request && request["plan"].isString) {
        broker.plan = request["plan"].getString;
    }
    if ("region" in request && request["region"].isString) {
        broker.region = request["region"].getString;
    }
    if ("status" in request && request["status"].isString) {
        broker.status = toLower(request["status"].get!string);
    }

    return broker;
}
}

