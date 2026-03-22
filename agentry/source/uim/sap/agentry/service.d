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
class AGTService : SAPService {
  mixin(SAPServiceTemplate!AGTService);

  private AGTStore _store;

  this(AGTConfig config) {
    super(config);

    _store = new AGTStore;
  }

  Json upsertMobileApp(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    AGTConfig cfg = cast(AGTConfig)config;
    auto app = AGTMobileApp(tenantId, request, cfg.defaultBackendSystem);
    if (app.name.length == 0) {
      throw new AGTValidationException("App name is required");
    }

    app.updatedAt = Clock.currTime();
    auto saved = _store.upsertApp(app);

    return Json.emptyObject
      .set("success", true)
      .set("mobile_app", saved.toJson());
  }

  Json listMobileApps(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = _store.listApps(tenantId).map!(app => app.toJson()).array.toJson();

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json createVersion(UUID tenantId, string appId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(appId, "App ID");

    auto app = _store.getApp(tenantId, appId);
    if (app.appId.toString.length == 0) {
      throw new AGTNotFoundException("Mobile app", tenantId ~ "/" ~ appId);
    }

    auto appVersion = AGTAppVersion(tenantId, appId, request);
    if (appVersion.versionLabel.length == 0) {
      throw new AGTValidationException("version_label is required");
    }

    auto saved = _store.addVersion(appVersion);

    return Json.emptyObject
      .set("success", true)
      .set("version", saved.toJson());
  }

  Json listVersions(UUID tenantId, string appId) {
    validateId(tenantId, "Tenant ID");
    validateId(appId, "App ID");

    Json resources = _store.listVersions(tenantId, appId)
      .map!(appVersion => appVersion.toJson()).array.toJson();

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("app_id", appId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json triggerTestRun(UUID tenantId, string appId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(appId, "App ID");

    auto app = _store.getApp(tenantId, appId);
    if (app.appId.toString.length == 0) {
      throw new AGTNotFoundException("Mobile app", tenantId ~ "/" ~ appId);
    }

    auto testRun = AGTTestRun(tenantId, appId, request);
    if (testRun.versionId.toString.length == 0) {
      auto versions = _store.listVersions(tenantId, appId);
      if (versions.length == 0) {
        throw new AGTValidationException("No version exists for test run; provide version_id");
      }
      testRun.versionId = versions[$ - 1].versionId;
    }

    auto saved = _store.addTestRun(testRun);

    return Json.emptyObject
      .set("success", true)
      .set("test_run", saved.toJson());
  }

  Json listTestRuns(UUID tenantId, string appId) {
    validateId(tenantId, "Tenant ID");
    validateId(appId, "App ID");

    Json resources = _store.listTestRuns(tenantId, appId)
      .map!(testRun => testRun.toJson()).array.toJson();

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("app_id", appId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json upsertRuntimeInstance(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto instance = AGTRuntimeInstance(tenantId, request);
    if (instance.appId.toString.length == 0) {
      throw new AGTValidationException("app_id is required");
    }

    auto app = _store.getApp(tenantId, instance.appId.toString);
    if (app.appId.toString.length == 0) {
      throw new AGTNotFoundException("Mobile app", tenantId ~ "/" ~ instance.appId.toString);
    }

    instance.updatedAt = Clock.currTime();
    auto saved = _store.upsertInstance(instance);

    return Json.emptyObject
      .set("success", true)
      .set("runtime_instance", saved.toJson());
  }

  Json listRuntimeInstances(UUID tenantId) {
    return listRuntimeInstances(tenantId.toString);
  }

  Json listRuntimeInstances(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (instance; _store.listInstances(tenantId)) {
      resources ~= instance.toJson();
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json deployVersion(UUID tenantId, UUID instanceId, Json request) {
    return deployVersion(tenantId.toString, instanceId.toString, request);
  }

  Json deployVersion(UUID tenantId, UUID instanceId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(instanceId, "Instance ID");

    auto instance = _store.getInstance(tenantId, instanceId);
    if (instance.instanceId.toString.length == 0) {
      throw new AGTNotFoundException("Runtime instance", tenantId ~ "/" ~ instanceId);
    }

    if (!("version_id" in request) || request["version_id"].type != Json.Type.string) {
      throw new AGTValidationException("version_id is required");
    }

    auto versionId = request["version_id"].get!string;
    auto versions = _store.listVersions(tenantId, instance.appId.toString);
    bool knownVersion = false;
    foreach (appVersion; versions) {
      if (appVersion.versionId == UUID(versionId)) {
        knownVersion = true;
        break;
      }
    }
    if (!knownVersion) {
      throw new AGTNotFoundException("App version", tenantId ~ "/" ~ versionId);
    }

    instance.deployedVersionId = UUID(versionId);
    instance.status = "running";
    if ("status" in request && request["status"].isString) {
      instance.status = request["status"].get!string.toLower;
    }
    instance.updatedAt = Clock.currTime();

    auto saved = _store.upsertInstance(instance);

    return Json.emptyObject
      .set("success", true)
      .set("runtime_instance", saved.toJson())
      .set("message", "Version deployed to runtime instance");
  }

  Json upsertDevice(UUID tenantId, Json request) {
    return upsertDevice(tenantId.toString, request);
  }

  Json upsertDevice(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto device = AGTDevice(tenantId, request);
    if (device.appId.toString.length == 0) {
      throw new AGTValidationException("app_id is required");
    }
    
    if (device.userId.toString.length == 0) {
      throw new AGTValidationException("user_id is required");
    }

    auto app = _store.getApp(tenantId, device.appId.toString);
    if (app.appId.toString.length == 0) {
      throw new AGTNotFoundException("Mobile app", tenantId ~ "/" ~ device.appId.toString);
    }

    device.lastSyncAt = Clock.currTime();
    auto saved = _store.upsertDevice(device);

    return Json.emptyObject
      .set("success", true)
      .set("device", saved.toJson());
  }

  Json listDevices(UUID tenantId) {
    return listDevices(tenantId.toString);
  }

  Json listDevices(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = _store.listDevices(tenantId).map!(device => device.toJson()).array.toJson();

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json syncDevice(UUID tenantId, UUID deviceId, Json request) {
    return syncDevice(tenantId.toString, deviceId.toString, request);
  }

  Json syncDevice(UUID tenantId, string deviceId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(deviceId, "Device ID");

    auto device = _store.getDevice(tenantId, deviceId);
    if (device.deviceId.toString.length == 0) {
      throw new AGTNotFoundException("Device", tenantId ~ "/" ~ deviceId);
    }

    if ("app_version_id" in request && request["app_version_id"].isString) {
      device.appVersionId = UUID(request["app_version_id"].get!string);
    }
    device.lastSyncAt = Clock.currTime();
    auto saved = _store.upsertDevice(device);

    return Json.emptyObject
      .set("success", true)
      .set("device", saved.toJson())
      .set("message", "Synchronization completed");
  }

  Json upsertBackendSystem(UUID tenantId, Json request) {
    return upsertBackendSystem(tenantId.toString, request);
  }

  Json upsertBackendSystem(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto backend = AGTBackendSystem(tenantId, request);
    if (backend.endpoint.length == 0) {
      throw new AGTValidationException("endpoint is required");
    }

    backend.updatedAt = Clock.currTime();
    auto saved = _store.upsertBackend(backend);

    return Json.emptyObject
      .set("success", true)
      .set("backend_system", saved.toJson());
  }

  Json listBackendSystems(UUID tenantId) {
    return listBackendSystems(tenantId.toString);
  }

  Json listBackendSystems(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = _store.listBackends(tenantId).map!(backend => backend.toJson()).array.toJson();

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json operationsDashboard(UUID tenantId) {
    return operationsDashboard(tenantId.toString);
  }

  Json operationsDashboard(UUID tenantId) {
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

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("mobile_apps", cast(long)apps.length)
      .set("runtime_instances", cast(long)instances.length)
      .set("running_instances", runningInstances)
      .set("registered_devices", cast(long)devices.length)
      .set("backend_systems", cast(long)backends.length);
  }
}
