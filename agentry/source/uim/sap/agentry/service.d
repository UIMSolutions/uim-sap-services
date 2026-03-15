/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.service;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

/**
  * AgentryService implements the core business logic for managing mobile applications, runtime instances, devices, and backend systems in the Agentry UIM service.
  * It provides methods for creating, updating, and listing these resources, as well as triggering test runs and deploying app versions to runtime instances.
  * The service uses an underlying AgentryStore for data persistence and ensures thread safety through synchronization.
  *
  * Each method validates input parameters, interacts with the store to perform the necessary operations, and constructs JSON responses to be returned to API clients.
  *
  * The service also includes an operationsDashboard method that aggregates key metrics about the tenant's resources for monitoring purposes.
  *
  * Error handling is implemented through custom exceptions such as AgentryValidationException and AgentryNotFoundException, which provide meaningful error messages for invalid input or missing resources.
  *
  * Overall, AgentryService serves as the main entry point for handling API requests related to mobile app management in the Agentry UIM service.
  *
  * Note: This implementation is designed for demonstration purposes and may need further enhancements for production use, such as authentication, authorization, and more robust error handling.
  */
class AgentryService : SAPService {
  mixin(SAPServiceTemplate!AgentryService);

  private AgentryStore _store;

  this(AgentryConfig config) {
    super(config);

    _store = new AgentryStore;
  }

  Json upsertMobileApp(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto app = appFromJson(tenantId, request, _config.defaultBackendSystem);
    if (app.name.length == 0) {
      throw new AgentryValidationException("App name is required");
    }

    app.updatedAt = Clock.currTime();
    auto saved = _store.upsertApp(app);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["mobile_app"] = saved.toJson();
    return result;
  }

  Json listMobileApps(string tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (app; _store.listApps(tenantId)) {
      resources ~= app.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json createVersion(string tenantId, string appId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(appId, "App ID");

    auto app = _store.getApp(tenantId, appId);
    if (app.appId.length == 0) {
      throw new AgentryNotFoundException("Mobile app", tenantId ~ "/" ~ appId);
    }

    auto appVersion = versionFromJson(tenantId, appId, request);
    if (appVersion.versionLabel.length == 0) {
      throw new AgentryValidationException("version_label is required");
    }

    auto saved = _store.addVersion(appVersion);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["version"] = saved.toJson();
    return result;
  }

  Json listVersions(string tenantId, string appId) {
    validateId(tenantId, "Tenant ID");
    validateId(appId, "App ID");

    Json resources = Json.emptyArray;
    foreach (appVersion; _store.listVersions(tenantId, appId)) {
      resources ~= appVersion.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["app_id"] = appId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json triggerTestRun(string tenantId, string appId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(appId, "App ID");

    auto app = _store.getApp(tenantId, appId);
    if (app.appId.length == 0) {
      throw new AgentryNotFoundException("Mobile app", tenantId ~ "/" ~ appId);
    }

    auto testRun = testRunFromJson(tenantId, appId, request);
    if (testRun.versionId.length == 0) {
      auto versions = _store.listVersions(tenantId, appId);
      if (versions.length == 0) {
        throw new AgentryValidationException("No version exists for test run; provide version_id");
      }
      testRun.versionId = versions[$ - 1].versionId;
    }

    auto saved = _store.addTestRun(testRun);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["test_run"] = saved.toJson();
    return result;
  }

  Json listTestRuns(string tenantId, string appId) {
    validateId(tenantId, "Tenant ID");
    validateId(appId, "App ID");

    Json resources = Json.emptyArray;
    foreach (testRun; _store.listTestRuns(tenantId, appId)) {
      resources ~= testRun.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["app_id"] = appId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json upsertRuntimeInstance(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto instance = instanceFromJson(tenantId, request);
    if (instance.appId.length == 0) {
      throw new AgentryValidationException("app_id is required");
    }

    auto app = _store.getApp(tenantId, instance.appId);
    if (app.appId.length == 0) {
      throw new AgentryNotFoundException("Mobile app", tenantId ~ "/" ~ instance.appId);
    }

    instance.updatedAt = Clock.currTime();
    auto saved = _store.upsertInstance(instance);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["runtime_instance"] = saved.toJson();
    return result;
  }

  Json listRuntimeInstances(string tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (instance; _store.listInstances(tenantId)) {
      resources ~= instance.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json deployVersion(string tenantId, string instanceId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(instanceId, "Instance ID");

    auto instance = _store.getInstance(tenantId, instanceId);
    if (instance.instanceId.length == 0) {
      throw new AgentryNotFoundException("Runtime instance", tenantId ~ "/" ~ instanceId);
    }

    if (!("version_id" in request) || request["version_id"].type != Json.Type.string) {
      throw new AgentryValidationException("version_id is required");
    }

    auto versionId = request["version_id"].get!string;
    auto versions = _store.listVersions(tenantId, instance.appId);
    bool knownVersion = false;
    foreach (appVersion; versions) {
      if (appVersion.versionId == versionId) {
        knownVersion = true;
        break;
      }
    }
    if (!knownVersion) {
      throw new AgentryNotFoundException("App version", tenantId ~ "/" ~ versionId);
    }

    instance.deployedVersionId = versionId;
    instance.status = "running";
    if ("status" in request && request["status"].isString) {
      instance.status = toLower(request["status"].get!string);
    }
    instance.updatedAt = Clock.currTime();

    auto saved = _store.upsertInstance(instance);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["runtime_instance"] = saved.toJson();
    result["message"] = "Version deployed to runtime instance";
    return result;
  }

  Json upsertDevice(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto device = deviceFromJson(tenantId, request);
    if (device.appId.length == 0) {
      throw new AgentryValidationException("app_id is required");
    }
    if (device.userId.length == 0) {
      throw new AgentryValidationException("user_id is required");
    }

    auto app = _store.getApp(tenantId, device.appId);
    if (app.appId.length == 0) {
      throw new AgentryNotFoundException("Mobile app", tenantId ~ "/" ~ device.appId);
    }

    device.lastSyncAt = Clock.currTime();
    auto saved = _store.upsertDevice(device);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["device"] = saved.toJson();
    return result;
  }

  Json listDevices(string tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (device; _store.listDevices(tenantId)) {
      resources ~= device.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json syncDevice(string tenantId, string deviceId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(deviceId, "Device ID");

    auto device = _store.getDevice(tenantId, deviceId);
    if (device.deviceId.length == 0) {
      throw new AgentryNotFoundException("Device", tenantId ~ "/" ~ deviceId);
    }

    if ("app_version_id" in request && request["app_version_id"].isString) {
      device.appVersionId = request["app_version_id"].get!string;
    }
    device.lastSyncAt = Clock.currTime();
    auto saved = _store.upsertDevice(device);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["device"] = saved.toJson();
    result["message"] = "Synchronization completed";
    return result;
  }

  Json upsertBackendSystem(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto backend = backendFromJson(tenantId, request);
    if (backend.endpoint.length == 0) {
      throw new AgentryValidationException("endpoint is required");
    }

    backend.updatedAt = Clock.currTime();
    auto saved = _store.upsertBackend(backend);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["backend_system"] = saved.toJson();
    return result;
  }

  Json listBackendSystems(string tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (backend; _store.listBackends(tenantId)) {
      resources ~= backend.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json operationsDashboard(string tenantId) {
    validateId(tenantId, "Tenant ID");

    auto apps = _store.listApps(tenantId);
    auto instances = _store.listInstances(tenantId);
    auto devices = _store.listDevices(tenantId);
    auto backends = _store.listBackends(tenantId);

    long runningInstances = 0;
    foreach (instance; instances) {
      if (instance.status == "running") {
        ++runningInstances;
      }
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["mobile_apps"] = cast(long)apps.length;
    result["runtime_instances"] = cast(long)instances.length;
    result["running_instances"] = runningInstances;
    result["registered_devices"] = cast(long)devices.length;
    result["backend_systems"] = cast(long)backends.length;
    return result;
  }

  private void validateId(string value, string fieldName) {
    if (value.length == 0) {
      throw new AgentryValidationException(fieldName ~ " cannot be empty");
    }
  }
}
