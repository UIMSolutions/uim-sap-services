/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cis.models.riskpolicy;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

/** 
 * Model representing a risk policy in the UIM Cloud Identity Services (CIS) module.
 * This struct defines the properties of a risk policy, which can be used to enforce
 * security measures based on various conditions such as IP ranges, user groups, and authentication methods.
 *
 * Fields:
 * - `tenantId`: The ID of the tenant this policy belongs to.
 * - `policyId`: The unique ID of the risk policy.
 * - `ipRanges`: A JSON array of IP ranges that are considered risky.
 * - `groups`: A JSON array of user groups that this policy applies to.
 * - `userType`: The type of users this policy applies to (e.g., "employee", "contractor").
 * - `authenticationMethod`: The authentication method required for users matching this policy (e.g., "password", "two_factor").
 * - `requireTwoFactor`: A boolean indicating whether two-factor authentication is required for users matching this policy.
 * - `updatedAt`: The timestamp of when the policy was last updated.
 * 
  * Methods:
  * - `toJson()`: Converts the risk policy to a JSON object for API responses.
  * Example usage:
  * ```
  * CISRiskPolicy policy;
  * policy.tenantId = "tenant123";
  * policy.policyId = "policy456";
  * policy.ipRanges = Json(["192.168.1.0/24", "10.0.0.0/8"]);
  * policy.groups = Json(["admin", "finance"]);
  * policy.userType = "employee";
  * policy.authenticationMethod = "two_factor";
  * policy.requireTwoFactor = true;
  * policy.updatedAt = Clock.currTime();
  * Json policyJson = policy.toJson();
  * ```
  * 
  * Note: The `toJson()` method is used to serialize the risk policy into a JSON format that can be returned in API responses or stored in a database. The actual implementation of the `toJson()` method may vary based on the specific requirements of the application and the structure of the JSON payload expected by the API consumers. 
  * The `ipRanges` field allows administrators to specify which IP addresses or ranges are considered risky, while the `groups` field enables targeting specific user groups for the application of the risk policy. The `userType` and `authenticationMethod` fields provide additional granularity in defining the conditions under which the risk policy should be enforced. The `requireTwoFactor` field is a critical component that indicates whether users matching the criteria defined in the policy must use two-factor authentication to access resources, thereby enhancing security. The `updatedAt` field is essential for tracking changes to the policy and ensuring that the most current version is being applied.  
 */
struct CISRiskPolicy {
  string tenantId;
  string policyId;
  Json ipRanges;
  Json groups;
  string userType;
  string authenticationMethod;
  bool requireTwoFactor = true;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["policy_id"] = policyId;
    payload["tenant_id"] = tenantId;
    payload["ip_ranges"] = ipRanges;
    payload["groups"] = groups;
    payload["user_type"] = userType;
    payload["authentication_method"] = authenticationMethod;
    payload["require_two_factor"] = requireTwoFactor;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
