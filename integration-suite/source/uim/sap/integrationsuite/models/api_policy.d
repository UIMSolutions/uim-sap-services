/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.api_policy;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct INTApiPolicy {
  UUID tenantId;
  UUID policyId;
  string name;
  string description;
  string policyType = "security"; // security | traffic | mediation
  string enforcement = "request"; // request | response | fault
  bool enabled = true;
  Json configuration;
  string createdAt;
  string updatedAt;

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("policy_id", policyId)
      .set("name", name)
      .set("description", description)
      .set("policy_type", policyType)
      .set("enforcement", enforcement)
      .set("enabled", enabled)
      .set("configuration", configuration)
      .set("created_at", createdAt)
      .set("updated_at", updatedAt);
  }
}

INTApiPolicy apiPolicyFromJson(UUID tenantId, Json request) {
  INTApiPolicy p;
  p.tenantId = tenantId;
  p.policyId = randomUUID();

  if ("name" in request && request["name"].isString)
    p.name = request["name"].getString;
  if ("description" in request && request["description"].isString)
    p.description = request["description"].getString;
  if ("policy_type" in request && request["policy_type"].isString)
    p.policyType = request["policy_type"].getString;
  if ("enforcement" in request && request["enforcement"].isString)
    p.enforcement = request["enforcement"].getString;
  if ("enabled" in request && request["enabled"].isBoolean)
    p.enabled = request["enabled"].get!bool;
  if ("configuration" in request)
    p.configuration = request["configuration"];
  else
    p.configuration = Json.emptyObject;

  p.createdAt = Clock.currTime().toINTOExtString();
  p.updatedAt = p.createdAt;
  return p;
}
