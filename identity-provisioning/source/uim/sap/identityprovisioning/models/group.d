/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.identityprovisioning.models.group;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

/** A group identity that is provisioned between systems. */
struct IPVGroup {
  string tenantId;
  string groupId;
  string externalId;
  string groupName;
  string displayName;
  string description;
  string[] memberUserIds;
  string sourceSystemId;
  string status = "synced"; // "synced" | "pending" | "error" | "skipped"
  string createdAt;
  string updatedAt;

  Json toJson() const {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["group_id"] = groupId;
    j["external_id"] = externalId;
    j["group_name"] = groupName;
    j["display_name"] = displayName;
    j["description"] = description;

    Json members = Json.emptyArray;
    foreach (uid; memberUserIds) {
      members ~= Json(uid);
    }
    j["member_user_ids"] = members;

    j["source_system_id"] = sourceSystemId;
    j["status"] = status;
    j["created_at"] = createdAt;
    j["updated_at"] = updatedAt;
    return j;
  }
}

IPVGroup groupFromJson(string tenantId, Json request) {
  IPVGroup g;
  g.tenantId = tenantId;
  g.groupId = randomUUID().toString();

  if ("group_name" in request && request["group_name"].isString)
    g.groupName = request["group_name"].get!string;
  if ("external_id" in request && request["external_id"].isString)
    g.externalId = request["external_id"].get!string;
  if ("display_name" in request && request["display_name"].isString)
    g.displayName = request["display_name"].get!string;
  if ("description" in request && request["description"].isString)
    g.description = request["description"].get!string;
  if ("source_system_id" in request && request["source_system_id"].isString)
    g.sourceSystemId = request["source_system_id"].get!string;
  if ("status" in request && request["status"].isString)
    g.status = request["status"].get!string;
  if ("group_id" in request && request["group_id"].isString)
    g.groupId = request["group_id"].get!string;

  if ("member_user_ids" in request && request["member_user_ids"].isArray) {
    () @trusted {
      foreach (item; request["member_user_ids"]) {
        if (item.isString)
          g.memberUserIds ~= item.get!string;
      }
    }();
  }

  g.createdAt = Clock.currTime().toISOExtString();
  g.updatedAt = g.createdAt;
  return g;
}
