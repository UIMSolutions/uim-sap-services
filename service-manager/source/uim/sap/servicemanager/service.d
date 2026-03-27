module uim.sap.servicemanager.service;

import std.datetime : Clock;
import std.string : toLower;

import uim.sap.servicemanager;

mixin(ShowModule!());

@safe:

private enum string[] SVM_OFFERINGS = [
    "hana-cloud",
    "destination",
    "connectivity",
    "alert-notification",
    "audit-log",
    "event-mesh",
    "identity-authentication"
  ];

class SVMService : SAPService {
  mixin(SAPServiceTemplate!SVMService);

  private SVMStore _store;

  this(SVMConfig config) {
    super(config);
    _store = new SVMStore();
  }

  Json discovery() {
    Json resources = Json.emptyArray;
    resources ~= endpoint("GET", "/v1/marketplace/offerings", "Service Marketplace overview");
    resources ~= endpoint("GET", "/v1/tenants/{tenantId}/service-offerings", "List service offerings for account");
    resources ~= endpoint("GET|POST", "/v1/tenants/{tenantId}/platforms", "Manage connected runtime platforms");
    resources ~= endpoint("GET|POST", "/v1/tenants/{tenantId}/service-instances", "Manage service instances");
    resources ~= endpoint("PATCH|DELETE", "/v1/tenants/{tenantId}/service-instances/{instanceId}", "Manage runtime instance lifecycle");
    resources ~= endpoint("POST", "/v1/tenants/{tenantId}/service-instances/{instanceId}/shares", "Share service instances across environments");
    resources ~= endpoint("GET|POST", "/v1/tenants/{tenantId}/service-bindings", "Manage service bindings");
    resources ~= endpoint("POST", "/v1/tenants/{tenantId}/runtime/instances/{instanceId}/actions/{action}", "Runtime instance management actions");

    return Json.emptyObject
      .set("service", "service-manager")
      .set("version", UIM_SERVICE_MANAGER_VERSION)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json marketplaceOfferings() {
    Json resources = Json.emptyArray;
    foreach (offering; SVM_OFFERINGS) {
      resources ~= Json.emptyObject
        .set("offering_name", offering)
        .set("provider", "SAP BTP")
        .set("plans", Json.emptyArray)
        .set("plans", "standard")
        .set("plans", "enterprise");
    }

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length)
      .set("catalog_scope", "global-marketplace");
  }

  Json serviceOfferings(UUID tenantId) {
    validateTenant(tenantId);

    return marketplaceOfferings()
      .set("tenant_id", tenantId)
      .set("catalog_scope", "account");
  }

  Json upsertPlatform(UUID tenantId, Json request) {
    validateTenant(tenantId);

    auto platform = parsePlatform(tenantId, request);
    if (platform.name.length == 0) {
      throw new SVMValidationException("name is required");
    }
    if (platform.apiEndpoint.length == 0) {
      throw new SVMValidationException("api_endpoint is required");
    }

    auto saved = _store.upsertPlatform(platform);
    return Json.emptyObject
      .set("success", true)
      .set("platform", saved.toJson());
  }

  Json listPlatforms(UUID tenantId) {
    validateTenant(tenantId);

    Json resources = Json.emptyArray;
    foreach (platform; _store.listPlatforms(tenantId)) {
      resources ~= platform.toJson();
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json deletePlatform(UUID tenantId, string platformId) {
    validateTenant(tenantId);
    if (platformId.length == 0) {
      throw new SVMValidationException("platformId cannot be empty");
    }

    if (!_store.deletePlatform(tenantId, platformId)) {
      throw new SVMNotFoundException("Platform", tenantId ~ "/" ~ platformId);
    }

    return Json.emptyObject
      .set("success", true)
      .set("platform_id", platformId);
  }

  Json upsertServiceInstance(UUID tenantId, Json request) {
    validateTenant(tenantId);

    auto instanceItem = parseServiceInstance(tenantId, request);
    if (instanceItem.offeringName.length == 0) {
      throw new SVMValidationException("offering_name is required");
    }
    if (instanceItem.planName.length == 0) {
      throw new SVMValidationException("plan_name is required");
    }
    if (instanceItem.environmentId.length == 0) {
      throw new SVMValidationException("environment_id is required");
    }

    instanceItem.updatedAt = Clock.currTime();
    auto saved = _store.upsertInstance(instanceItem);

    return Json.emptyObject
      .set("success", true)
      .set("service_instance", saved.toJson());
  }

  Json listServiceInstances(UUID tenantId) {
    validateTenant(tenantId);

    Json resources = Json.emptyArray;
    foreach (instanceItem; _store.listInstances(tenantId)) {
      resources ~= instanceItem.toJson();
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json patchServiceInstance(UUID tenantId, UUID instanceId, Json request) {
    validateTenant(tenantId);

    auto current = _store.getInstance(tenantId, instanceId);
    if (current.instanceId.length == 0) {
      throw new SVMNotFoundException("Service instance", tenantId ~ "/" ~ instanceId);
    }

    if ("status" in request && request["status"].isString) {
      current.status = request["status"].getString;
    }
    if ("environment_id" in request && request["environment_id"].isString) {
      current.environmentId = request["environment_id"].getString;
    }
    current.updatedAt = Clock.currTime();

    auto saved = _store.upsertInstance(current);
    return Json.emptyObject
      .set("success", true)
      .set("service_instance", saved.toJson());
  }

  Json deleteServiceInstance(UUID tenantId, UUID instanceId) {
    validateTenant(tenantId);

    if (!_store.deleteInstance(tenantId, instanceId)) {
      throw new SVMNotFoundException("Service instance", tenantId ~ "/" ~ instanceId);
    }

    return Json.emptyObject
      .set("success", true)
      .set("instance_id", instanceId);
  }

  Json shareServiceInstance(UUID tenantId, UUID instanceId, Json request) {
    validateTenant(tenantId);

    auto current = _store.getInstance(tenantId, instanceId);
    if (current.instanceId.length == 0) {
      throw new SVMNotFoundException("Service instance", tenantId ~ "/" ~ instanceId);
    }

    if (!("target_environment" in request) || !request["target_environment"].isString) {
      throw new SVMValidationException("target_environment is required");
    }

    auto target = request["target_environment"].getString;
    if (target.length == 0) {
      throw new SVMValidationException("target_environment cannot be empty");
    }

    bool exists = false;
    foreach (envId; current.sharedToEnvironments) {
      if (envId == target) {
        exists = true;
        break;
      }
    }
    if (!exists) {
      current.sharedToEnvironments ~= target;
    }
    current.updatedAt = Clock.currTime();

    auto saved = _store.upsertInstance(current);
    return Json.emptyObject
      .set("success", true)
      .set("service_instance", saved.toJson());
  }

  Json upsertServiceBinding(UUID tenantId, Json request) {
    validateTenant(tenantId);

    auto binding = parseServiceBinding(tenantId, request);
    if (binding.instanceId.length == 0) {
      throw new SVMValidationException("instance_id is required");
    }
    if (binding.name.length == 0) {
      throw new SVMValidationException("name is required");
    }

    auto instanceItem = _store.getInstance(tenantId, binding.instanceId);
    if (instanceItem.instanceId.length == 0) {
      throw new SVMNotFoundException("Service instance", tenantId ~ "/" ~ binding.instanceId);
    }

    auto saved = _store.upsertBinding(binding);
    return Json.emptyObject
      .set("success", true)
      .set("service_binding", saved.toJson());
  }

  Json listServiceBindings(UUID tenantId) {
    validateTenant(tenantId);

    Json resources = Json.emptyArray;
    foreach (binding; _store.listBindings(tenantId)) {
      resources ~= binding.toJson();
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json deleteServiceBinding(UUID tenantId, string bindingId) {
    validateTenant(tenantId);

    if (!_store.deleteBinding(tenantId, bindingId)) {
      throw new SVMNotFoundException("Service binding", tenantId ~ "/" ~ bindingId);
    }

    return Json.emptyObject
      .set("success", true)
      .set("binding_id", bindingId);
  }

  Json runtimeInstanceAction(UUID tenantId, UUID instanceId, string action) {
    validateTenant(tenantId);

    auto current = _store.getInstance(tenantId, instanceId);
    if (current.instanceId.length == 0) {
      throw new SVMNotFoundException("Service instance", tenantId ~ "/" ~ instanceId);
    }

    auto normalized = toLower(action);
    if (normalized == "provision" || normalized == "resume" || normalized == "start") {
      current.status = "running";
    } else if (normalized == "suspend" || normalized == "stop") {
      current.status = "suspended";
    } else if (normalized == "deprovision") {
      current.status = "deprovisioned";
    } else {
      throw new SVMValidationException("Unsupported runtime action: " ~ action);
    }

    current.updatedAt = Clock.currTime();
    auto saved = _store.upsertInstance(current);

    return Json.emptyObject
      .set("success", true)
      .set("action", normalized)
      .set("service_instance", saved.toJson());
  }

  private Json endpoint(string method, string path, string description) {
    return Json.emptyObject
      .set("method", method)
      .set("path", path)
      .set("description", description);
  }
}
