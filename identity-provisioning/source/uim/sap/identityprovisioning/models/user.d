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
class IPVUser : SAPTenantEntity {
  mixin(SAPTenantEntity!IPVUser);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("user_id" in request && request["user_id"].isString) {
      userId = UUID(request["user_id"].getString);
    }
    if ("external_id" in request && request["external_id"].isString) {
      externalId = UUID(request["external_id"].getString);
    }
    if ("user_name" in request && request["user_name"].isString) {
      userName = request["user_name"].getString;
    }
    if ("email" in request && request["email"].isString) {
      email = request["email"].getString;
    }
    if ("first_name" in request && request["first_name"].isString) {
      firstName = request["first_name"].getString;
    }
    if ("last_name" in request && request["last_name"].isString) {
      lastName = request["last_name"].getString;
    }
    if ("display_name" in request && request["display_name"].isString) {
      displayName = request["display_name"].getString;
    }
    if ("active" in request && request["active"].isBoolean) {
      active = request["active"].get!bool;
    }
    if ("source_system_id" in request && request["source_system_id"].isString) {
      sourceSystemId = request["source_system_id"].getString;
    }
    if ("status" in request && request["status"].isString) {
      status = request["status"].getString;

    }
    if ("group_ids" in request && request["group_ids"].isArray) {
      foreach (item; request["group_ids"].toArray) {
        if (item.isString)
          groupIds ~= item.getString;
      }

      u.userId = randomUUID();

      if ("user_name" in request && request["user_name"].isString)
        u.userName = request["user_name"].getString;
      if ("external_id" in request && request["external_id"].isString)
        u.externalId = request["external_id"].getString;
      if ("email" in request && request["email"].isString)
        u.email = request["email"].getString;
      if ("first_name" in request && request["first_name"].isString)
        u.firstName = request["first_name"].getString;
      if ("last_name" in request && request["last_name"].isString)
        u.lastName = request["last_name"].getString;
      if ("display_name" in request && request["display_name"].isString)
        u.displayName = request["display_name"].getString;
      if ("active" in request && request["active"].isBoolean)
        u.active = request["active"].get!bool;
      if ("source_system_id" in request && request["source_system_id"].isString)
        u.sourceSystemId = request["source_system_id"].getString;
      if ("status" in request && request["status"].isString)
        u.status = request["status"].getString;
      if ("user_id" in request && request["user_id"].isString)
        u.userId = request["user_id"].getString;

      if ("group_ids" in request && request["group_ids"].isArray) {
        foreach (item; request["group_ids"].toArray) {
          if (item.isString)
            u.groupIds ~= item.getString;
        }
      }

      u.createdAt = Clock.currTime();
      u.updatedAt = u.createdAt;
      u.lastModifiedAt = u.createdAt;

      return true;
    }

    UUID userId;
    UUID externalId; // ID in the external system
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

    override Json toJson() {
      auto gids = groupIds.map!(gid => gid.toJson).array;

      return super.toJson()
        .set("user_id", userId)
        .set("external_id", externalId)
        .set("user_name", userName)
        .set("email", email)
        .set("first_name", firstName)
        .set("last_name", lastName)
        .set("display_name", displayName)
        .set("active", active)
        .set("group_ids", gids)
        .set("source_system_id", sourceSystemId)
        .set("status", status)
        .set("last_modified_at", lastModifiedAt);
    }
  }

  IPVUser userFromJson(UUID tenantId, Json request) {
    IPVUser u = new IPVUser(request);
    u.tenantId = tenantId;

    return u;
  }
