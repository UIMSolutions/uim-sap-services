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
  string systemId;
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

  override Json toJson()  {
    return super.toJson()
    j["tenant_id"] = tenantId;
    j["system_id"] = systemId;
    j["system_name"] = systemName;
    j["description"] = description;
    j["system_type"] = systemType;
    j["connector_type"] = connectorType;
    j["endpoint_url"] = endpointUrl;
    j["auth_type"] = authType;
    j["status"] = status;
    j["user_count"] = userCount;
    j["group_count"] = groupCount;
    j["last_sync_at"] = lastSyncAt;
    j["created_at"] = createdAt;
    j["updated_at"] = updatedAt;
    return j;
  }
}

IPVSystem systemFromJson(UUID tenantId, Json request) {
  IPVSystem s;
  s.tenantId = UUID(tenantId);
  s.systemId = randomUUID().toString();

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

  s.createdAt = Clock.currTime().toISOExtString();
  s.updatedAt = s.createdAt;
  return s;
}
