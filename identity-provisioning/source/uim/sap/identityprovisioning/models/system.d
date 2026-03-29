/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.identityprovisioning.models.system;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

/** A provisioning system — either source or target.
 *
 *  Source systems are read from during provisioning jobs.
 *  Target systems are written to.
 *  A system may be both (proxy mode).
 *
 *  `systemType` values: "source", "target", "proxy"
 *  `connectorType` values: "sap-ias", "sap-sf", "scim", "ldap", "custom", …
 */
class IPVSystem : SAPTenantEntity {
  mixin(SAPTenantEntity!IPVSystem);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("system_id" in request && request["system_id"].isString) {
      systemId = UUID(request["system_id"].get!string);
    }
    if ("system_name" in request && request["system_name"].isString) {
      systemName = request["system_name"].getString;
    }
    if ("description" in request && request["description"].isString) {
      description = request["description"].getString;
    }
    if ("system_type" in request && request["system_type"].isString) {
      systemType = request["system_type"].getString;
    }
    if ("connector_type" in request && request["connector_type"].isString) {
      connectorType = request["connector_type"].getString;
    }
    if ("endpoint_url" in request && request["endpoint_url"].isString) {
      endpointUrl = request["endpoint_url"].getString;
    }
    if ("auth_type" in request && request["auth_type"].isString) {
      authType = request["auth_type"].getString;
    }
    if ("status" in request && request["status"].isString) {
      status = request["status"].getString;
    }
    if ("user_count" in request && request["user_count"].isNumber) {
      userCount = cast(long)request["user_count"].getNumber;
    }
    if ("group_count" in request && request["group_count"].isNumber) {
      groupCount = cast(long)request["group_count"].getNumber;
    }
    if ("last_sync_at" in request && request["last_sync_at"].isString) {
      lastSyncAt = request["last_sync_at"].getString; // ISO 8601 string
    }

    s.systemId = randomUUID();

    if ("system_name" in request && request["system_name"].isString)
      s.systemName = request["system_name"].getString;
    if ("description" in request && request["description"].isString)
      s.description = request["description"].getString;
    if ("system_type" in request && request["system_type"].isString)
      s.systemType = request["system_type"].getString;
    if ("connector_type" in request && request["connector_type"].isString)
      s.connectorType = request["connector_type"].getString;
    if ("endpoint_url" in request && request["endpoint_url"].isString)
      s.endpointUrl = request["endpoint_url"].getString;
    if ("auth_type" in request && request["auth_type"].isString)
      s.authType = request["auth_type"].getString;
    if ("status" in request && request["status"].isString)
      s.status = request["status"].getString;
    if ("system_id" in request && request["system_id"].isString)
      s.systemId = request["system_id"].getString;

    s.createdAt = Clock.currTime();
    s.updatedAt = s.createdAt;
    if (systemId == UUID.nil) {
      systemId = randomUUID();
    }
    if (createdAt == "") {
      createdAt = Clock.currTime();
    }
    updatedAt = createdAt;
    return true;
  }

  UUID systemId;
  string systemName;
  string description;
  string systemType = "source"; // "source" | "target" | "proxy"
  string connectorType = "scim"; // "sap-ias" | "sap-sf" | "scim" | "ldap" | "custom"
  string endpointUrl;
  string authType = "basic"; // "basic" | "bearer" | "oauth2" | "certificate"
  string status = "active"; // "active" | "inactive" | "error"
  long userCount = 0;
  long groupCount = 0;
  string lastSyncAt;

  override Json toJson() {
    return super.toJson()
      .set("system_id", systemId)
      .set("system_name", systemName)
      .set("description", description)
      .set("system_type", systemType)
      .set("connector_type", connectorType)
      .set("endpoint_url", endpointUrl)
      .set("auth_type", authType)
      .set("status", status)
      .set("user_count", userCount)
      .set("group_count", groupCount)
      .set("last_sync_at", lastSyncAt);
  }
}

IPVSystem systemFromJson(UUID tenantId, Json request) {
  IPVSystem s = new IPVSystem(request);
  s.tenantId = tenantId;

  return s;
}
