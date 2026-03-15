/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.models.brokerservice;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

class AEMBrokerService : SAPTenantObject {
  mixin(SAPObjectTemplate!AEMBrokerService);

  UUID brokerServiceId;
  string name;
  string plan;
  string region;
  string status = "running";

  long connectedClients;
  long eventsPublished;

  override Json toJson() const {
    Json payload = super.toJson();
    payload["broker_service_id"] = brokerServiceId.toString();
    payload["name"] = name;
    payload["plan"] = plan;
    payload["region"] = region;
    payload["status"] = status;
    payload["connected_clients"] = connectedClients;
    payload["events_published"] = eventsPublished;
    return payload;
  }
}

AEMBrokerService brokerFromJson(string tenantId, Json request, string defaultRegion) {
    AEMBrokerService broker = new AEMBrokerService();
    broker.tenantId = tenantId;
    broker.brokerServiceId = randomUUID().toString();
    broker.plan = "standard";
    broker.region = defaultRegion;
    broker.createdAt = Clock.currTime();
    broker.updatedAt = broker.createdAt;

    if ("broker_service_id" in request && request["broker_service_id"].isString) {
        broker.brokerServiceId = request["broker_service_id"].get!string;
    }
    if ("name" in request && request["name"].isString) {
        broker.name = request["name"].get!string;
    }
    if ("plan" in request && request["plan"].isString) {
        broker.plan = request["plan"].get!string;
    }
    if ("region" in request && request["region"].isString) {
        broker.region = request["region"].get!string;
    }
    if ("status" in request && request["status"].isString) {
        broker.status = toLower(request["status"].get!string);
    }

    return broker;
}