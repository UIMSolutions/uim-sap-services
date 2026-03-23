/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cis.service;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

/**
  * The `CISService` class is the core service implementation for the UIM Cloud Identity Services (CIS) module. It provides methods to handle various operations related to identity management, such as user and group management, authentication, authorization, provisioning jobs, and notification subscriptions. The service interacts with a `CISStore` instance to persist and retrieve data related to users, groups, policies, and other entities. Each method in the `CISService` class is designed to validate input parameters, perform the necessary business logic, and return a JSON response that can be consumed by API clients. The service also includes helper methods for validating user input and ensuring that the provided data meets the required criteria before processing. 
  * Example usage:
  * ``` 
  * CISConfig config = new CISConfig();
  * config.host = "https://example.com";
  * config.port = 8088;
  * config.basePath = "/api/cis";
  * config.serviceName = "uim-cis";
  * config.serviceVersion = "1.0.0";
  * config.defaultAuthMethod = "form";
  * config.requireAuthToken(true);
  * config.authToken = "my-secret-token";
  * config.validate();
  * CISService service = new CISService(config);
  * Json healthResponse = service.health();
  * Json readyResponse = service.ready();
  * Json authCapabilities = service.authenticationCapabilities();
  * Json loginResponse = service.login("tenant123", Json({"userName": "jdoe", "method": "form"}));
  * Json upsertUserResponse = service.upsertUser("tenant123", Json({"userName": "jdoe", "email": "jdoe@example.com"}));
  * Json listUsersResponse = service.listUsers("tenant123");
  * Json upsertGroupResponse = service.upsertGroup("tenant123", Json({"displayName": "Admins"}));
  * Json listGroupsResponse = service.listGroups("tenant123");
  * Json inviteUserResponse = service.inviteUser("tenant123", Json({"email": "jdoe@example.com"}));
  * 
  * Note: The example usage demonstrates how to initialize the `CISService` with a configuration, and then call various methods to perform operations such as checking health and readiness, retrieving authentication capabilities, logging in a user, managing users and groups, and inviting a user. Each method returns a JSON response that contains the relevant information based on the operation performed. The actual implementation of the methods may include additional logic for error handling, data validation, and interaction with the underlying store to manage the state of users, groups, policies, and other entities within the CIS module.   
  */
class CISService : SAPService {
  mixin(SAPServiceTemplate!CISService);

  private CISStore _store;

  this(CISConfig config) {
    config.validate();
    _store = new CISStore;
  }

  Json authenticationCapabilities() {
    Json methods = CIS_AUTH_METHODS.toJson;
    Json protocols = CIS_SSO_PROTOCOLS.toJson;

    return Json.emptyObject
      .set("supported_authentication_methods", methods)
      .set("supported_sso_protocols", protocols)
      .set("api_authentication_supported", true)
      .set("default_authentication_method", _config.defaultAuthMethod);
  }

  Json login(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto method = _config.defaultAuthMethod;
    if ("method" in request && request["method"].isString) {
      method = toLower(request["method"].get!string);
    }
    validateAuthMethod(method);

    string userName;
    if ("userName" in request && request["userName"].isString) {
      userName = request["userName"].get!string;
    }

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["tenant_id"] = tenantId;
    payload["method"] = method;
    payload["sso_protocol"] = "openid-connect";
    payload["token_type"] = "Bearer";
    payload["access_token"] = createId();
    payload["subject"] = userName;
    return payload;
  }

  Json upsertUser(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto user = CISUser(tenantId, request);
    validateUser(user);
    user.updatedAt = Clock.currTime();
    auto saved = _store.upsertUser(user);

    return Json.emptyObject
      .set("success", true)
      .set("user", saved.toJson())
      .set("identity_directory", true);
  }

  Json listUsers(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (user; _store.listUsers(tenantId))
      resources ~= user.toJson();

    Json schemas = Json.emptyArray;
    schemas ~= "urn:ietf:params:scim:api:messages:2.0:ListResponse";
    return Json.emptyObject
      .set("Resources", resources)
      .set("totalResults", cast(long)resources.length)
      .set("schemas", schemas);
  }

  Json upsertGroup(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto group = CISGroup(tenantId, request);
    if (group.displayName.length == 0) {
      throw new CISValidationException("displayName is required");
    }
    group.updatedAt = Clock.currTime();
    auto saved = _store.upsertGroup(group);

    return Json.emptyObject
      .set("success", true)
      .set("group", saved.toJson());
  }

  Json listGroups(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (group; _store.listGroups(tenantId))
      resources ~= group.toJson();

    Json schemas = Json.emptyArray;
    schemas ~= "urn:ietf:params:scim:api:messages:2.0:ListResponse";
    return Json.emptyObject
      .set("Resources", resources)
      .set("totalResults", cast(long)resources.length)
      .set("schemas", schemas);
  }

  Json inviteUser(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    if (!("email" in request) || !request["email"].isString || request["email"].get!string.length == 0) {
      throw new CISValidationException("email is required");
    }

    return Json.emptyObject
      .set("success", true)
      .set("tenant_id", tenantId)
      .set("email", request["email"].get!string)
      .set("invitation_id", createId());
  }

  Json setUiText(UUID tenantId, string locale, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(locale, "Locale");

    return Json.emptyObject
      .set("success", true)
      .set("tenant_id", tenantId)
      .set("locale", locale)
      .set("texts", request)
      .set("message", "End-user UI texts updated");
  }

  Json upsertDelegationRule(UUID tenantId, string ruleId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(ruleId, "Rule ID");

    CISDelegationRule rule;
    rule.tenantId = UUID(tenantId);
    rule.ruleId = ruleId;
    rule.updatedAt = Clock.currTime();

    if ("target_idp" in request && request["target_idp"].isString)
      rule.targetIdp = request["target_idp"].get!string;
    if ("is_default" in request && request["is_default"].isBoolean)
      rule.isDefault = request["is_default"].get!bool;
    if ("email_domain" in request && request["email_domain"].isString)
      rule.emailDomain = request["email_domain"].get!string;
    if ("user_type" in request && request["user_type"].isString)
      rule.userType = request["user_type"].get!string;
    if ("group" in request && request["group"].isString)
      rule.group = request["group"].get!string;

    if (rule.targetIdp.length == 0)
      throw new CISValidationException("target_idp is required");

    auto saved = _store.upsertDelegationRule(rule);

    return Json.emptyObject
      .set("success", true)
      .set("rule", saved.toJson())
      .set("delegates_authentication", true);
  }

  Json listDelegationRules(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (rule; _store.listDelegationRules(tenantId))
      resources ~= rule.toJson();

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json upsertPolicy(UUID tenantId, string policyId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(policyId, "Policy ID");

    CISAuthorizationPolicy policy = new CISAuthorizationPolicy;
    policy.tenantId = UUID(tenantId);
    policy.policyId = policyId;
    policy.updatedAt = Clock.currTime();
    policy.allowedGroups = Json.emptyArray;
    policy.allowedUserTypes = Json.emptyArray;

    if ("name" in request && request["name"].isString)
      policy.name = request["name"].get!string;
    if ("resource_type" in request && request["resource_type"].isString)
      policy.resourceType = request["resource_type"].get!string;
    if ("instance_id" in request && request["instance_id"].isString)
      policy.instanceId = request["instance_id"].get!string;
    if ("allowed_groups" in request && request["allowed_groups"].isArray)
      policy.allowedGroups = request["allowed_groups"];
    if ("allowed_user_types" in request && request["allowed_user_types"].isArray)
      policy.allowedUserTypes = request["allowed_user_types"];

    if (policy.name.length == 0 || policy.resourceType.length == 0 || policy.instanceId.length == 0) {
      throw new CISValidationException("name, resource_type and instance_id are required");
    }

    auto saved = _store.upsertPolicy(policy);
    return Json.emptyObject
      .set("success", true)
      .set("policy", saved.toJson());
  }

  Json listPolicies(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (policy; _store.listPolicies(tenantId))
      resources ~= policy.toJson();

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json authorize(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    if (!("instance_id" in request) || request["instance_id"].type != Json.Type.string) {
      throw new CISValidationException("instance_id is required");
    }

    auto instanceId = request["instance_id"].get!string;
    string group;
    string userType;
    if ("group" in request && request["group"].isString)
      group = request["group"].get!string;
    if ("user_type" in request && request["user_type"].isString)
      userType = request["user_type"].get!string;

    bool allowed = false;
    foreach (policy; _store.listPolicies(tenantId)) {
      if (policy.instanceId != instanceId)
        continue;
      if (arrayContains(policy.allowedGroups, group) || arrayContains(policy.allowedUserTypes, userType)) {
        allowed = true;
        break;
      }
    }

    return Json.emptyObject
      .set("authorized", allowed)
      .set("instance_id", instanceId);
  }

  Json upsertRiskPolicy(UUID tenantId, string policyId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(policyId, "Policy ID");

    CISRiskPolicy policy = new CISRiskPolicy(request);
    policy.tenantId = UUID(tenantId);
    policy.policyId = policyId;
    policy.updatedAt = Clock.currTime();
    policy.ipRanges = Json.emptyArray;
    policy.groups = Json.emptyArray;

    if ("ip_ranges" in request && request["ip_ranges"].isArray)
      policy.ipRanges = request["ip_ranges"];
    if ("groups" in request && request["groups"].isArray)
      policy.groups = request["groups"];
    if ("user_type" in request && request["user_type"].isString)
      policy.userType = request["user_type"].get!string;
    if ("authentication_method" in request && request["authentication_method"].isString)
      policy.authenticationMethod = toLower(request["authentication_method"].get!string);
    if ("require_two_factor" in request && request["require_two_factor"].isBoolean)
      policy.requireTwoFactor = request["require_two_factor"].get!bool;

    validateAuthMethod(policy.authenticationMethod);
    auto saved = _store.upsertRiskPolicy(policy);

    return Json.emptyObject
      .set("success", true)
      .set("risk_policy", saved.toJson());
  }

  Json listRiskPolicies(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    auto resources = _store.listRiskPolicies(tenantId).map!(policy => policy.toJson).array;

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json evaluateRisk(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    string ip;
    string group;
    string userType;
    string method;

    if ("ip" in request && request["ip"].isString)
      ip = request["ip"].get!string;
    if ("group" in request && request["group"].isString)
      group = request["group"].get!string;
    if ("user_type" in request && request["user_type"].isString)
      userType = request["user_type"].get!string;
    if ("authentication_method" in request && request["authentication_method"].isString)
      method = toLower(request["authentication_method"].get!string);

    bool force2FA = false;
    foreach (policy; _store.listRiskPolicies(tenantId)) {
      if (policy.requireTwoFactor && (
          arrayContains(policy.ipRanges, ip) ||
          arrayContains(policy.groups, group) ||
          (policy.userType.length > 0 && policy.userType == userType) ||
          (policy.authenticationMethod.length > 0 && policy.authenticationMethod == method)
        )) {
        force2FA = true;
        break;
      }
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("require_two_factor", force2FA)
      .set("evaluated", true);
  }

  Json startProvisioningJob(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    CISProvisioningJob job;
    job.tenantId = UUID(tenantId);
    job.jobId = createId();
    job.createdAt = Clock.currTime();
    job.updatedAt = job.createdAt;
    job.status = "running";
    job.mode = "full";
    job.filters = Json.emptyObject;

    if ("job_id" in request && request["job_id"].isString)
      job.jobId = request["job_id"].get!string;
    if ("source_system" in request && request["source_system"].isString)
      job.sourceSystem = request["source_system"].get!string;
    if ("target_system" in request && request["target_system"].isString)
      job.targetSystem = request["target_system"].get!string;
    if ("mode" in request && request["mode"].isString)
      job.mode = normalizeMode(request["mode"].get!string);
    if ("filters" in request && request["filters"].isObject)
      job.filters = request["filters"];

    if (job.sourceSystem.length == 0 || job.targetSystem.length == 0) {
      throw new CISValidationException("source_system and target_system are required");
    }

    auto saved = _store.upsertJob(job);

    CISJobLog startLog = new CISJobLog;
    startLog.tenantId = UUID(tenantId);
    startLog.logId = createId();
    startLog.jobId = saved.jobId;
    startLog.level = "INFO";
    startLog.message = "Provisioning job started";
    startLog.createdAt = Clock.currTime();
    _store.appendJobLog(startLog);

    return Json.emptyObject
      .set("success", true)
      .set("job", saved.toJson());
  }

  Json listProvisioningJobs(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    auto resources = _store.listJobs(tenantId).map!(job => job.toJson).array;

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json listJobLogs(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    auto resources = _store.listJobLogs(tenantId).map!(log => log.toJson).array;

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json subscribeNotifications(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    CISNotificationSubscription sub = new CISNotificationSubscription;
    sub.tenantId = UUID(tenantId);
    sub.subscriptionId = createId();
    sub.updatedAt = Clock.currTime();

    if ("subscription_id" in request && request["subscription_id"].isString)
      sub.subscriptionId = request["subscription_id"].get!string;
    if ("source_system" in request && request["source_system"].isString)
      sub.sourceSystem = request["source_system"].get!string;
    if ("callback_url" in request && request["callback_url"].isString)
      sub.callbackUrl = request["callback_url"].get!string;

    if (sub.sourceSystem.length == 0 || sub.callbackUrl.length == 0) {
      throw new CISValidationException("source_system and callback_url are required");
    }

    auto saved = _store.upsertSubscription(sub);
    return Json.emptyObject
      .set("success", true)
      .set("subscription", saved.toJson());
  }

  Json listNotificationSubscriptions(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (sub; _store.listSubscriptions(tenantId))
      resources ~= sub.toJson();

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  private void validateUser(CISUser user) {
    if (user.userName.length == 0)
      throw new CISValidationException("userName is required");
    if (user.email.length == 0)
      throw new CISValidationException("email is required");
  }

  private void validateAuthMethod(string method) {
    if (method != "form" && method != "spnego" && method != "social" && method != "2fa") {
      throw new CISValidationException("Unsupported authentication method: " ~ method);
    }
  }

  private bool arrayContains(Json arrayValue, string needle) {
    return needle.length == 0 || !arrayValue.isArray
      ? false : arrayValue.toArray.any!(item => item.isString && item.get!string == needle);
  }
}
