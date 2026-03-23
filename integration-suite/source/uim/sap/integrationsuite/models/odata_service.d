/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.odata_service;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct INTODataService {
  UUID tenantId;
  string serviceId;
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

  override Json toJson()  {
    
    Json sets = Json.emptyArray;
    foreach (s; entitySets)
      sets ~= Json(s);

        return super.toJson()
    .set("tenant_id", tenantId)
    .set("service_id", serviceId)
    .set("name", name)
    .set("description", description)
    .set("service_url", serviceUrl)
    .set("odata_version", odataVersion)
    .set("backend_system", backendSystem)
    .set("entity_sets", sets)
    .set("status", status)
    .set("query_count", queryCount)
    .set("created_at", createdAt)
    .set("updated_at", updatedAt);
  }
}

INTODataService odataServiceFromJson(UUID tenantId, Json request) {
  INTODataService svc;
  svc.tenantId = tenantId;
  svc.serviceId = randomUUID().toString();

  if ("name" in request && request["name"].isString)
    svc.name = request["name"].get!string;
  if ("description" in request && request["description"].isString)
    svc.description = request["description"].get!string;
  if ("service_url" in request && request["service_url"].isString)
    svc.serviceUrl = request["service_url"].get!string;
  if ("odata_version" in request && request["odata_version"].isString)
    svc.odataVersion = request["odata_version"].get!string;
  if ("backend_system" in request && request["backend_system"].isString)
    svc.backendSystem = request["backend_system"].get!string;
  if ("entity_sets" in request && request["entity_sets"].isArray) {
    foreach (item; request["entity_sets"]) {
      if (item.isString)
        svc.entitySets ~= item.get!string;
    }
  }

  svc.createdAt = Clock.currTime().toINTOExtString();
  svc.updatedAt = svc.createdAt;
  return svc;
}
