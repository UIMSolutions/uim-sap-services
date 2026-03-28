/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.api_policy;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/**
  * Represents an API policy in the SAP Integration Suite.
  * Contains properties for policy configuration and enforcement.
  * Can be extended to support specific types of policies (e.g. security, traffic management).
  *
  * Example usage:
  * class MyCustomPolicy : INTApiPolicy {
  *   override bool initialize(Json[string] initData = null) {
  *     if (!super.initialize(initData)) {
  *       return false;
  *     }
  *     // Custom initialization logic here
  *     return true;
  *   }
  * }
  */
class INTApiPolicy : SAPTenantObject {
  mixin(SAPObjectTemplate!INTApiPolicy);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }
    if (initData !is null) {
      if (initData.hasKey("policyId") && initData.isString("policyId")) {
        policyId(initData.getString("policyId"));
      }
      if (initData.hasKey("name") && initData.isString("name")) {
        name(initData.getString("name"));
      }
      if (initData.hasKey("description") && initData.isString("description")) {
        description(initData.getString("description"));
      }
      if (initData.hasKey("policyType") && initData.isString("policyType")) {
        policyType(initData.getString("policyType"));
      }
      if (initData.hasKey("enforcement") && initData.isString("enforcement")) {
        enforcement(initData.getString("enforcement"));
      }
      if (initData.hasKey("enabled") && initData.isBoolean("enabled")) {
        enabled(initData.get!bool("enabled"));
      }
      if (initData.hasKey("configuration")) {
        configuration(initData["configuration"]);
      }
    }

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
    return true;
  }

  UUID policyId;
  string name;
  string description;
  string policyType = "security"; // security | traffic | mediation
  string enforcement = "request"; // request | response | fault
  bool enabled = true;
  Json configuration;

  override Json toJson() {
    return super.toJson()
      .set("policy_id", policyId)
      .set("name", name)
      .set("description", description)
      .set("policy_type", policyType)
      .set("enforcement", enforcement)
      .set("enabled", enabled)
      .set("configuration", configuration);
  }
}

INTApiPolicy apiPolicyFromJson(UUID tenantId, Json request) {
  INTApiPolicy p = new INTApiPolicy(request);
  p.tenantId = tenantId;

  return p;
}
