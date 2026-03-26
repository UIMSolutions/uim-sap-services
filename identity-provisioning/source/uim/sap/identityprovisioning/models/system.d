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
struct IPVSystem {
  UUID tenantId;
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
  string createdAt;
  string updatedAt;

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
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
      .set("last_sync_at", lastSyncAt)
      .set("created_at", createdAt)
      .set("updated_at", updatedAt);
  }
}

IPVSystem systemFromJson(UUID tenantId, Json request) {
  IPVSystem s;
  s.tenantId = tenantId;
  s.systemId = randomUUID();

  if ("system_name" in request && request["system_name"].isString)
    s.systemName = request["system_name"].get!string;
  if ("description" in request && request["description"].isString)
    s.description = request["description"].get!string;
  if ("system_type" in request && request["system_type"].isString)
    s.systemType = request["system_type"].get!string;
  if ("connector_type" in request && request["connector_type"].isString)
    s.connectorType = request["connector_type"].get!string;
  if ("endpoint_url" in request && request["endpoint_url"].isString)
    s.endpointUrl = request["endpoint_url"].get!string;
  if ("auth_type" in request && request["auth_type"].isString)
    s.authType = request["auth_type"].get!string;
  if ("status" in request && request["status"].isString)
    s.status = request["status"].get!string;
  if ("system_id" in request && request["system_id"].isString)
    s.systemId = request["system_id"].get!string;

  s.createdAt = Clock.currTime();
  s.updatedAt = s.createdAt;
  return s;
}
