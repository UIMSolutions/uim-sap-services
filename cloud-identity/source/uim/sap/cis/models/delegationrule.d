/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cis.models.delegationrule;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

/** 
  * Model representing a delegation rule in the UIM Cloud Identity Services (CIS) module.
  * A delegation rule defines how authentication requests are delegated to a target identity provider (IdP) based on specific criteria such as email domain, user type, or group membership.
  * 
  * Fields:
  * - `tenantId`: The ID of the tenant to which the delegation rule belongs.
  * - `ruleId`: The unique identifier for the delegation rule.
  * - `targetIdp`: The target identity provider to which authentication requests should be delegated when the rule criteria are met.
  * - `isDefault`: A boolean indicating whether this rule is the default delegation rule for the tenant.
  * - `emailDomain`: The email domain that this delegation rule applies to (e.g., "example.com").
  * - `userType`: The type of users that this delegation rule applies to (e.g., "employee", "contractor").
  * - `group`: The user group that this delegation rule applies to (e.g., "admins", "developers").
  * - `updatedAt`: The timestamp indicating when the delegation rule was last updated.
  * Methods:
  * - `toJson()`: Converts the delegation rule to a JSON object for API responses or storage.
  * Example usage:
  * ```
  * CISDelegationRule rule;
  * rule.tenantId = "tenant123";
  * rule.ruleId = "rule456";      
  * rule.targetIdp = "idp789";
  * rule.isDefault = false;
  * rule.emailDomain = "example.com";
  * rule.userType = "employee";
  * rule.group = "admins";
  * rule.updatedAt = Clock.currTime();
  * Json ruleJson = rule.toJson();
  * ```
  * Note: The `toJson()` method is used to serialize the delegation rule into a JSON format that can be returned in API responses or stored in a database. The actual implementation of the `toJson()` method may vary based on the specific requirements of the application and the structure of the
  * JSON payload expected by the API consumers. The `emailDomain`, `userType`, and `group` fields allow for defining specific criteria for when the delegation rule should be applied, while the `isDefault` field indicates whether this rule should be used as the default delegation mechanism when no other rules match. The `updatedAt` field is essential for tracking changes to the delegation rule and ensuring that the most current version is being applied in authentication scenarios.
  * Delegation rules are a critical component of the authentication flow in the CIS module, enabling flexible and dynamic routing of authentication requests to different identity providers based on user attributes and organizational policies. By defining delegation rules, administrators can ensure that users are authenticated through the appropriate channels, enhancing security and user experience. The combination of criteria such as email domain, user type, and group membership allows for granular control over the delegation process, making it possible to implement complex authentication scenarios that align with the organization's requirements. 
  */
class CISDelegationRule : SAPTenantObject {
  mixin(SAPObjectTemplate!CISDelegationRule);

  UUID ruleId;
  string targetIdp;
  bool isDefault = false;
  string emailDomain;
  string userType;
  string group;

  override Json toJson() {
    return super.toJson
      .set("rule_id", ruleId)
      .set("target_idp", targetIdp)
      .set("is_default", isDefault)
      .set("email_domain", emailDomain)
      .set("user_type", userType)
      .set("group", group);
  }
}
