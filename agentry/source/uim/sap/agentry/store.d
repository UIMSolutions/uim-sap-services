/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.store;

import core.sync.mutex : Mutex;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:
class AGTStore : SAPStore {
  mixin(SAPStoreTemplate!AGTStore);

  protected AGTTenant[UUID] _tenants;
  AGTTenant tenant(UUID tenantId) {
    synchronized (_lock) {
      return _tenants.get(tenantId, null);
    }
  }

  AGTTenant tenant(AGTTenant tenant) {
    synchronized (_lock) {
      _tenants[tenant.tenantId] = tenant;
      return tenant;
    }
  }

  AGTMobileApp upsertApp(AGTMobileApp app) {
    synchronized (_lock) {
      auto tenant = tenant(app.tenantId);
      if (tenant is null) {
        return null;
      }

      tenant.app(app);
      return app;
    }
  }

  AGTMobileApp getApp(UUID tenantId, UUID appId) {
    return getApp(tenantId.toString, appId.toString);
  }

  AGTMobileApp getApp(UUID tenantId, string appId) {
    synchronized (_lock) {
      auto tenant = tenant(tenantId);
      if (tenant is null) {
        return null;
      }

      return tenant.app(appId);
    }
  }

  AGTMobileApp[] listApps(UUID tenantId) {
    auto tenant = tenant(tenantId);
    if (tenant is null) {
      return null;
    }

    return tenant.apps;
  }

  AGTMobileApp[] listApps(UUID tenantId) {
    synchronized (_lock) {
      auto tenant = tenant(tenantId);
      if (tenant is null) {
        return null;
      }

      return tenant.apps;
    }
  }

  AGTAppVersion addVersion(AGTAppVersion appVersion) {
    synchronized (_lock) {
      auto tenant = tenant(appVersion.tenantId);
      if (tenant is null) {
        return null;
      }

      tenant.versions(appVersion.appId, tenant.versions(appVersion.appId) ~= appVersion);
      return appVersion;
    }
  }

  AGTAppVersion[] listVersions(UUID tenantId, UUID appId) {
    synchronized (_lock) {
      auto tenant = tenant(tenantId);
      if (tenant is null) {
        return null;
      }

      return tenant.versions(appId);
    }
    return null;
  }

  AGTTestRun addTestRun(AGTTestRun testRun) {
    synchronized (_lock) {
      auto key = appKey(testRun.tenantId, testRun.appId);
      _testRunsByApp[key] ~= testRun;
      return testRun;
    }
  }

  AGTTestRun[] listTestRuns(UUID tenantId, UUID appId) {
    return listTestRuns(tenantId.toString, appId.toString);
  }

  AGTTestRun[] listTestRuns(UUID tenantId, string appId) {
    synchronized (_lock) {
      auto key = appKey(tenantId, appId);
      if (key in _testRunsByApp) {
        return _testRunsByApp[key].dup;
      }
    }
    return null;
  }

  AGTRuntimeInstance upsertInstance(AGTRuntimeInstance instance) {
    synchronized (_lock) {
      auto key = instanceKey(instance.tenantId, instance.instanceId);
      _instances[key] = instance;
      return instance;
    }
  }

  AGTRuntimeInstance getInstance(UUID tenantId, UUID instanceId) {
    return getInstance(tenantId.toString, instanceId.toString);
  }

  AGTRuntimeInstance getInstance(UUID tenantId, UUID instanceId) {
    synchronized (_lock) {
      auto key = instanceKey(tenantId, instanceId);
      if (key in _instances) {
        return _instances[key];
      }
    }
    return new AGTRuntimeInstance;
  }

  AGTRuntimeInstance[] listInstances(UUID tenantId) {
    return listInstances(tenantId.toString);
  }

  AGTRuntimeInstance[] listInstances(UUID tenantId) {
    AGTRuntimeInstance[] list;
    synchronized (_lock) {
      foreach (key, instance; _instances) {
        if (belongsToTenant(key, tenantId)) {
          list ~= instance;
        }
      }
    }
    return list;
  }

  AGTDevice upsertDevice(AGTDevice device) {
    synchronized (_lock) {
      auto key = deviceKey(device.tenantId, device.deviceId);
      _devices[key] = device;
      return device;
    }
  }

  AGTDevice getDevice(UUID tenantId, UUID deviceId) {
    synchronized (_lock) {
      auto tenant = getTenant(tenantId);
      if (tenant is null)
        return null;

      return tenant.device(deviceId);

      

      )
    }
  }

  AGTDevice[] listDevices(UUID tenantId) {
    return listDevices(tenantId.toString);
  }

  AGTDevice[] listDevices(UUID tenantId) {
    AGTDevice[] list;
    synchronized (_lock) {
      foreach (key, device; _devices) {
        if (belongsToTenant(key, tenantId)) {
          list ~= device;
        }
      }
    }
    return list;
  }

  AGTBackendSystem upsertBackend(AGTBackendSystem backend) {
    synchronized (_lock) {
      auto key = backendKey(backend.tenantId, backend.backendId);
      _backends[key] = backend;
      return backend;
    }
  }

  AGTBackendSystem[] listBackends(UUID tenantId) {
    return listBackends(tenantId.toString);
  }

  AGTBackendSystem[] listBackends(UUID tenantId) {
    AGTBackendSystem[] list;
    synchronized (_lock) {
      foreach (key, backend; _backends) {
        if (belongsToTenant(key, tenantId)) {
          list ~= backend;
        }
      }
    }
    return list;
  }

  private string appKey(UUID tenantId, UUID appId) {
    return appKey(tenantId.toString, appId.toString);
  }

  private string appKey(UUID tenantId, string appId) {
    return tenantId ~ ":app:" ~ appId;
  }

  private string instanceKey(UUID tenantId, UUID instanceId) {
    return instanceKey(tenantId.toString, instanceId.toString);
  }

  private string instanceKey(UUID tenantId, UUID instanceId) {
    return tenantId ~ ":instance:" ~ instanceId;
  }

  private string deviceKey(UUID tenantId, UUID deviceId) {
    return deviceKey(tenantId.toString, deviceId.toString);
  }

  private string deviceKey(UUID tenantId, string deviceId) {
    return tenantId ~ ":device:" ~ deviceId;
  }

  private string backendKey(UUID tenantId, UUID backendId) {
    return backendKey(tenantId.toString, backendId.toString);
  }

  private string backendKey(UUID tenantId, string backendId) {
    return tenantId ~ ":backend:" ~ backendId;
  }

  private bool belongsToTenant(string key, UUID tenantId) {
    return belongsToTenant(key, tenantId.toString);
  }

  private bool belongsToTenant(string key, UUID tenantId) {
    return key.length > tenantId.length + 1
      && key[0 .. tenantId.length] == tenantId
      && key[tenantId.length] == ':';
  }
}
