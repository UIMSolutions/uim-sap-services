/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cis.models.group;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

/** 
  * Model representing a user group in the UIM Cloud Identity Services (CIS) module.
  * This struct defines the properties of a user group, including the tenant ID, group ID, display name, members, and the last updated timestamp.
  * The `toJson()` method is provided to serialize the user group into a JSON format for API responses or storage purposes.
  * Fields:
  * - `tenantId`: The ID of the tenant this group belongs to.
  * - `groupId`: The unique ID of the user group.
  * - `displayName`: The display name of the user group. 
  * - `members`: A JSON array of user IDs that are members of this group.
  * - `updatedAt`: The timestamp of when the group was last updated.
  * Methods:
  * - `toJson()`: Converts the user group to a JSON object for API responses.
  * Example usage:  
  * ```
  *   CISGroup group;
  *   group.tenantId = "tenant123";
  *   group.groupId = "group123";
  *   group.displayName = "Test Group";
  *   group.members = Json(["user1", "user2"]);
  *   group.updatedAt = Clock.currTime();
  *   Json groupJson = group.toJson();
  * ```
  * Note: The `toJson()` method is used to serialize the user group into a JSON format that can be returned in API responses or stored in a database. The actual implementation of the `toJson()` method may vary based on the specific requirements of the application and the structure of the JSON payload expected by the API consumers. The `members` field is represented as a JSON array to allow for flexibility in defining multiple users that belong to the group. The `updatedAt` field is essential for tracking changes to the group and ensuring that the most current version is being applied. The `displayName` field provides a human-readable identifier for the group, which can be useful for administrators when managing multiple groups. 
  */
class CISGroup : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!CISGroup);

  UUID groupId;
  string displayName;
  Json members;

  override Json toJson() {
    return super.toJson()
      .set("id", groupId)
      .set("displayName", displayName)
      .set("members", members);
  }

  static CISGroup groupFromJson(UUID tenantId, Json request) {
    CISGroup group = new CISGroup(request);
    group.tenantId = tenantId;
    group.groupId = createId();
    group.updatedAt = Clock.currTime();
    group.members = Json.emptyArray;

    if ("id" in request && request["id"].isString)
      group.groupId = request["id"].getString;
    if ("displayName" in request && request["displayName"].isString)
      group.displayName = request["displayName"].getString;
    if ("members" in request && request["members"].isArray)
      group.members = request["members"];

    return group;
  }
}
