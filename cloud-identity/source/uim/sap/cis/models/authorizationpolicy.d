/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cis.models.authorizationpolicy;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

/** 
  * Model representing an authorization policy in the UIM Cloud Identity Services (CIS) module.
  * This struct defines the properties of an authorization policy, including the tenant ID, policy ID, name, resource type, instance ID, allowed groups, allowed user types, and the last updated timestamp.
  * The `toJson()` method is provided to serialize the authorization policy into a JSON format for API responses or storage purposes.
  * Fields:
  * - `tenantId`: The ID of the tenant this policy belongs to.
  * - `policyId`: The unique ID of the authorization policy.
  * - `name`: The name of the authorization policy. 
  * - `resourceType`: The type of resource this policy applies to (e.g., "application", "database").
  * - `instanceId`: The specific instance of the resource this policy applies to (e.g., "app123", "db456").
  * - `allowedGroups`: A JSON array of user groups that are allowed access under this policy.
  * - `allowedUserTypes`: A JSON array of user types that are allowed access under this policy (e.g., "employee", "contractor").
  * - `updatedAt`: The timestamp of when the policy was last updated.
  * Methods:
  * - `toJson()`: Converts the authorization policy to a JSON object for API responses.
  * Example usage:  
  * ```
  *   CISAuthorizationPolicy policy;
  *   policy.tenantId = "tenant123";
  *   policy.policyId = "policy456";
  *   policy.name = "Allow access to app123 for employees in admin group";
  *   policy.resourceType = "application";
  *   policy.instanceId = "app123";
  *   policy.allowedGroups = Json(["admin"]);
  *   policy.allowedUserTypes = Json(["employee"]);
  *   policy.updatedAt = Clock.currTime();
  *   Json policyJson = policy.toJson();
  * ```
  * Note: The `toJson()` method is used to serialize the authorization policy into a JSON format that can be returned in API responses or stored in a database. The actual implementation of the `toJson()` method may vary based on the specific requirements of the application and the structure of the JSON payload expected by the API consumers. The `allowedGroups` and `allowedUserTypes` fields are represented as JSON arrays to allow for flexibility in defining multiple groups and user types that the policy applies to. The
  * `resourceType` and `instanceId` fields help specify the exact resources that the policy governs, while the `updatedAt` field is essential for tracking changes to the policy and ensuring that the most current version is being applied. 
  * The `name` field provides a human-readable identifier for the policy, which can be useful for administrators when managing multiple policies. The combination of `resourceType` and `instanceId` allows for fine-grained control over which resources the policy applies to, enabling scenarios such as allowing access to a specific application or database instance. The `allowedGroups` and `allowedUserTypes` fields enable targeting specific user segments for access control, enhancing the security and manageability of the authorization policies within the CIS module. 
  */
class CISAuthorizationPolicy : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!CISAuthorizationPolicy);

  UUID policyId;
  string name;
  string resourceType;
  UUID instanceId;
  Json allowedGroups;
  Json allowedUserTypes;

  override Json toJson() {
    return super.toJson
      .set("policy_id", policyId.toJson)
      .set("name", name.toJson)
      .set("resource_type", resourceType.toJson)
      .set("instance_id", instanceId.toJson)
      .set("allowed_groups", allowedGroups)
      .set("allowed_user_types", allowedUserTypes);
  }
}
