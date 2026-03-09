/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.hybrid_runtime;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct INTHybridRuntime {
  string tenantId;
  string runtimeId;
  string name;
  string description;
  string location; // e.g. datacenter name or region
  string runtimeType = "integration"; // integration | api_management
  string status = "online"; // online | offline | error | maintenance
  string version_ = "1.0.0";
  long iflowCount = 0;
  long apiProxyCount = 0;
  string lastHeartbeat;
  string createdAt;
  string updatedAt;

  Json toJson() const {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["runtime_id"] = runtimeId;
    j["name"] = name;
    j["description"] = description;
    j["location"] = location;
    j["runtime_type"] = runtimeType;
    j["status"] = status;
    j["version"] = version_;
    j["iflow_count"] = iflowCount;
    j["api_proxy_count"] = apiProxyCount;
    j["last_heartbeat"] = lastHeartbeat;
    j["created_at"] = createdAt;
    j["updated_at"] = updatedAt;
    return j;
  }
}

INTHybridRuntime hybridRuntimeFromJson(string tenantId, Json request) {
  INTHybridRuntime r;
  r.tenantId = tenantId;
  r.runtimeId = randomUUID().toString();

  if ("name" in request && request["name"].isString)
    r.name = request["name"].get!string;
  if ("description" in request && request["description"].isString)
    r.description = request["description"].get!string;
  if ("location" in request && request["location"].isString)
    r.location = request["location"].get!string;
  if ("runtime_type" in request && request["runtime_type"].isString)
    r.runtimeType = request["runtime_type"].get!string;
  if ("version" in request && request["version"].isString)
    r.version_ = request["version"].get!string;

  r.createdAt = Clock.currTime().toINTOExtString();
  r.updatedAt = r.createdAt;
  return r;
}
