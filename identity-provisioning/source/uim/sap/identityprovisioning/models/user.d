/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.identityprovisioning.models.user;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

/** A user identity that is provisioned between systems. */
struct IPVUser {
  string tenantId;
  string userId;
  string externalId; // ID in the external system
  string userName;
  string email;
  string firstName;
  string lastName;
  string displayName;
  bool active = true;
  string[] groupIds; // groups this user belongs to
  string sourceSystemId; // which system this user was read from
  string status = "synced"; // "synced" | "pending" | "error" | "skipped"
  string lastModifiedAt;
  string createdAt;
  string updatedAt;

  override Json toJson()  {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["user_id"] = userId;
    j["external_id"] = externalId;
    j["user_name"] = userName;
    j["email"] = email;
    j["first_name"] = firstName;
    j["last_name"] = lastName;
    j["display_name"] = displayName;
    j["active"] = active;

    Json gids = Json.emptyArray;
    foreach (gid; groupIds) {
      gids ~= Json(gid);
    }
    j["group_ids"] = gids;

    j["source_system_id"] = sourceSystemId;
    j["status"] = status;
    j["last_modified_at"] = lastModifiedAt;
    j["created_at"] = createdAt;
    j["updated_at"] = updatedAt;
    return j;
  }
}

IPVUser userFromJson(string tenantId, Json request) {
  IPVUser u;
  u.tenantId = tenantId;
  u.userId = randomUUID().toString();

  if ("user_name" in request && request["user_name"].isString)
    u.userName = request["user_name"].get!string;
  if ("external_id" in request && request["external_id"].isString)
    u.externalId = request["external_id"].get!string;
  if ("email" in request && request["email"].isString)
    u.email = request["email"].get!string;
  if ("first_name" in request && request["first_name"].isString)
    u.firstName = request["first_name"].get!string;
  if ("last_name" in request && request["last_name"].isString)
    u.lastName = request["last_name"].get!string;
  if ("display_name" in request && request["display_name"].isString)
    u.displayName = request["display_name"].get!string;
  if ("active" in request && request["active"].type == Json.Type.bool_)
    u.active = request["active"].get!bool;
  if ("source_system_id" in request && request["source_system_id"].isString)
    u.sourceSystemId = request["source_system_id"].get!string;
  if ("status" in request && request["status"].isString)
    u.status = request["status"].get!string;
  if ("user_id" in request && request["user_id"].isString)
    u.userId = request["user_id"].get!string;

  if ("group_ids" in request && request["group_ids"].isArray) {
    () @trusted {
      foreach (item; request["group_ids"]) {
        if (item.isString)
          u.groupIds ~= item.get!string;
      }
    }();
  }

  u.createdAt = Clock.currTime().toISOExtString();
  u.updatedAt = u.createdAt;
  u.lastModifiedAt = u.createdAt;
  return u;
}
