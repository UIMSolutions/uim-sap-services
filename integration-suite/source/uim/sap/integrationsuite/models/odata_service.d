/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.odata_service;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class INTODataService : SAPTenantEntity {
  mixin(SAPTenantEntity!INTODataService);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("service_id" in request && request["service_id"].isString) {
      serviceId = request["service_id"].getString;
    }
    if ("name" in request && request["name"].isString) {
      name = request["name"].getString;
    }
    if ("description" in request && request["description"].isString) {
      description = request["description"].getString;
    }
    if ("service_url" in request && request["service_url"].isString) {
      serviceUrl = request["service_url"].getString;
    }
    if ("odata_version" in request && request["odata_version"].isString) {
      odataVersion = request["odata_version"].getString;
    }
    if ("backend_system" in request && request["backend_system"].isString) {
      backendSystem = request["backend_system"].getString;
    }
    if ("entity_sets" in request && request["entity_sets"].isArray) {
      foreach (item; request["entity_sets"].toArray) {
        if (item.isString) {
          entitySets ~= item.getString;
        }
      }
    }

    return true;
  }

  UUID serviceId;
  string name;
  string description;
  string serviceUrl;
  string odataVersion = "V2"; // V2 | V4
  string backendSystem; // e.g. ECC, S/4HANA
  string[] entitySets;
  string status = "active"; // active | inactive | error
  long queryCount = 0;
  string createdAt;
  string updatedAt;

  override Json toJson() {

    Json sets = Json.emptyArray;
    foreach (s; entitySets)
      sets ~= Json(s);

    return super.toJson()
      .set("service_id", serviceId)
      .set("name", name)
      .set("description", description)
      .set("service_url", serviceUrl)
      .set("odata_version", odataVersion)
      .set("backend_system", backendSystem)
      .set("entity_sets", sets)
      .set("status", status)
      .set("query_count", queryCount);
  }
}

INTODataService odataServiceFromJson(UUID tenantId, Json request) {
  INTODataService svc = new INTODataService(request);
  svc.tenantId = tenantId;

  svc.serviceId = randomUUID();
  svc.createdAt = Clock.currTime().toINTOExtString();
  svc.updatedAt = svc.createdAt;
  return svc;
}
