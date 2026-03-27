/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.hybrid_runtime;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/** 
  * Represents a hybrid runtime environment for SAP Integration Suite, which can host both integration flows and API proxies.
  * This model captures the essential attributes of a hybrid runtime, including its status, location, and capabilities.
  *
  * The INTHybridRuntime struct is designed to be flexible and extensible, allowing for future enhancements such as additional runtime types,
  * more detailed status information, or integration with monitoring and management tools.
  * For more information on hybrid runtimes and their management, refer to the SAP Integration Suite documentation.
  * 
  * Fields:
  * - tenantId: The ID of the tenant that owns this hybrid runtime. 
  * - runtimeId: A unique identifier for the hybrid runtime.
  * - name: The name of the hybrid runtime.
  * - description: A brief description of the hybrid runtime.
  * - location: The physical or logical location of the hybrid runtime (e.g., datacenter name or region).
  * - runtimeType: The type of the hybrid runtime (e.g., integration, api_management).
  * - status: The current status of the hybrid runtime (e.g., online, offline, error, maintenance).
  * - version: The version of the runtime environment.
  * - iflowCount: The number of integration flows currently deployed on this hybrid runtime.
  * - apiProxyCount: The number of API proxies currently deployed on this hybrid runtime.
  * - lastHeartbeat: The timestamp of the last successful heartbeat received from the hybrid runtime, indicating that it is operational.
  * - createdAt: The timestamp when the hybrid runtime was created.
  * - updatedAt: The timestamp when the hybrid runtime was last updated.
  * 
  * Methods:
  * - toJson(): Converts the hybrid runtime instance into a JSON representation for API responses or storage.
  * - hybridRuntimeFromJson(UUID tenantId, Json request): Creates a new hybrid runtime instance from a JSON request, generating a unique runtimeId and setting the createdAt and updatedAt timestamps
  * 
  * Statuses:
  * - online: The hybrid runtime is operational and can host integration flows and API proxies.
  * - offline: The hybrid runtime is currently offline and cannot host integration flows or API proxies.
  * - error: The hybrid runtime is in an error state and requires attention.
  * - maintenance: The hybrid runtime is under maintenance and may be temporarily unavailable.
  * 
  * Runtime Types:
  * - integration: The hybrid runtime is designed to host integration flows.
  * - api_management: The hybrid runtime is designed to host API proxies.
  *
  * For more information on hybrid runtimes and their management, refer to the SAP Integration Suite documentation.
  */
class INTHybridRuntime : SAPTenantObject {
  mixin(SAPtenantObject!INTHybridRuntime);

  UUID runtimeId;
  string name;
  string description;
  string location; // e.g. datacenter name or region
  string runtimeType = "integration"; // integration | api_management
  string status = "online"; // online | offline | error | maintenance
  string version_ = "1.0.0";
  long iflowCount = 0;
  long apiProxyCount = 0;
  string lastHeartbeat;

  override Json toJson() {
    return super.toJson()
      .set("runtime_id", runtimeId)
      .set("name", name)
      .set("description", description)
      .set("location", location)
      .set("runtime_type", runtimeType)
      .set("status", status)
      .set("version", version_)
      .set("iflow_count", iflowCount)
      .set("api_proxy_count", apiProxyCount)
      .set("last_heartbeat", lastHeartbeat)
      .set("created_at", createdAt)
      .set("updated_at", updatedAt);
  }

  static INTHybridRuntime hybridRuntimeFromJson(UUID tenantId, Json request) {
    INTHybridRuntime r = new INTHybridRuntime(request);
    r.tenantId = tenantId;
    r.runtimeId = randomUUID();

    if ("name" in request && request["name"].isString)
      r.name = request["name"].getString;
    if ("description" in request && request["description"].isString)
      r.description = request["description"].getString;
    if ("location" in request && request["location"].isString)
      r.location = request["location"].getString;
    if ("runtime_type" in request && request["runtime_type"].isString)
      r.runtimeType = request["runtime_type"].getString;
    if ("version" in request && request["version"].isString)
      r.version_ = request["version"].getString;

    r.createdAt = Clock.currTime().toINTOExtString();
    r.updatedAt = r.createdAt;
    return r;
  }
}
