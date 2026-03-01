module uim.sap.aem.models.brokerservice;

import uim.sap.aem;

mixin(ShowModule!());

@safe:


struct AEMBrokerService : SAPService {
  string tenantId;
  string brokerServiceId;
  string name;
  string plan;
  string region;
  string status = "running";

  long connectedClients;
  long eventsPublished;

  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["broker_service_id"] = brokerServiceId;
    payload["name"] = name;
    payload["plan"] = plan;
    payload["region"] = region;
    payload["status"] = status;
    payload["connected_clients"] = connectedClients;
    payload["events_published"] = eventsPublished;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

AEMBrokerService brokerFromJson(string tenantId, Json request, string defaultRegion) {
    AEMBrokerService broker;
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