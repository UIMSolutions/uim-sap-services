/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cis.models.user;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

/** 
 * Model representing a user in the UIM Cloud Identity Services (CIS) module.
 * This struct defines the properties of a user, including their ID, tenant association, username, email, user type, active status, group memberships, and custom attributes. It also includes timestamps for when the user was created and last updated.
 * The `toJson()` method is provided to serialize the user object into a JSON format that can be easily returned in API responses or stored in a database. The JSON payload includes all relevant user information, making it suitable for use in various contexts within the CIS module, such as provisioning jobs, notifications, and risk policies.
 * Fields:
 * - `tenantId`: The ID of the tenant this user belongs to.
 * - `userId`: The unique ID of the user. 
  * - `userName`: The username of the user.
  * - `email`: The email address of the user.
  * - `userType`: The type of user (e.g., "employee", "contractor").
  * - `active`: A boolean indicating whether the user is active.
  * - `groups`: A JSON array of groups the user belongs to.
  * - `attributes`: A JSON object containing custom attributes for the user.
  * - `createdAt`: The timestamp of when the user was created.
  * - `updatedAt`: The timestamp of when the user was last updated.       
  * Methods:
  * - `toJson()`: Converts the user object to a JSON format for API responses.
  * Example usage:
  * ```
  * CISUser user;
  * user.tenantId = "tenant123";
  * user.userId = "user456";
  * user.userName = "jdoe";
  * user.email = "jdoe@example.com";  
  * user.userType = "employee";
  * user.active = true;
  * user.groups = Json(["group1", "group2"]);
  * user.attributes = Json({"department": "sales", "location": "NY"});
  * user.createdAt = Clock.currTime();
  * user.updatedAt = Clock.currTime();
  * Json userJson = user.toJson();
  * ```
  * Note: The `toJson()` method is used to serialize the user object into a JSON format that can be returned in API responses or stored in a database. The actual implementation of the `toJson()` method may vary based on the specific requirements of the application and the structure of the JSON payload expected
  * by the API consumers. The `groups` field allows for representing the user's group memberships, while the `attributes` field provides flexibility for storing additional custom information about the user that may be relevant for provisioning, notifications, or risk policies within the CIS module. The `createdAt` and `updatedAt` fields are essential for tracking the lifecycle of the user object and ensuring that the most current information is being used in any operations involving the user. 
 */
class CISUser : SAPTenantObject {
  mixin(SAPObjectTemplate!CISUser);

  UUID userId;
  string userName;
  string email;
  string userType = "employee";
  bool active = true;
  Json groups;
  Json attributes;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    return super.toJson
      .set("id", userId)
      .set("userName", userName)
      .set("email", email)
      .set("user_type", userType)
      .set("active", active)
      .set("groups", groups)
      .set("attributes", attributes);
  }

  static CISUser opCall(UUID tenantId, Json request) {
    CISUser user;
    user.tenantId = tenantId;
    user.userId = createId();
    user.createdAt = Clock.currTime();
    user.updatedAt = user.createdAt;
    user.groups = Json.emptyArray;
    user.attributes = Json.emptyObject;

    if ("id" in request && request["id"].isString) {
      user.userId = request["id"].getString;
    }
    if ("userName" in request && request["userName"].isString) {
      user.userName = request["userName"].getString;
    }
    if ("email" in request && request["email"].isString) {
      user.email = request["email"].getString;
    }
    if ("user_type" in request && request["user_type"].isString) {
      user.userType = request["user_type"].getString;
    }
    if ("active" in request && request["active"].isBoolean) {
      user.active = request["active"].get!bool;
    }
    if ("groups" in request && request["groups"].isArray) {
      user.groups = request["groups"];
    }
    if ("attributes" in request && request["attributes"].isObject) {
      user.attributes = request["attributes"];
    }

    return user;
  }
}
