module uim.sap.agentry.tenant;

import core.sync.mutex : Mutex;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

class AGTTenant : SAPTenant {
  mixin(SAPStoreTemplate!AGTTenant);

  protected AGTMobileApp[UUID] _apps;
  AGTMobileApp[] apps() {
    synchronized (_lock) {
      return _apps.values;
    }
  }

  AGTMobileApp app(UUID appId) {
    synchronized (_lock) {
      return _apps.get(appId, null);
    }
  }

  void app(AGTMobileApp app) {
    if (app is null)
      return;

    synchronized (_lock) {
      _apps[app.appId] = app;
    }
  }

  protected AGTAppVersion[][UUID] _versionsByApp;
  AGTAppVersion[] versions(UUID appId) {
    synchronized (_lock) {
      return _versionsByApp.get(appId, null);
    }
  }

  void versions(UUID appId, AGTAppVersion[] versions) {
    if (versions is null)
      return;

    synchronized (_lock) {
      _versionsByApp[appId] = versions.dup;
    }
  }

  protected AGTTestRun[][UUID] _testRunsByApp;
  AGTTestRun[] testRuns(UUID appId) {
    synchronized (_lock) {
      return _testRunsByApp.get(appId, null);
    }
  }

  void testRuns(UUID appId, AGTTestRun[] testRuns) {
    if (testRuns is null)
      return;

    synchronized (_lock) {
      _testRunsByApp[appId] = testRuns.dup;
    }
  }

  protected AGTRuntimeInstance[UUID] _instances;
  AGTRuntimeInstance[] instances() {
    synchronized (_lock) {
      return _instances.values;
    }
  }

  AGTRuntimeInstance instance(UUID instanceId) {
    synchronized (_lock) {
      return _instances.get(instanceId, null);
    }
  }

  void instance(AGTRuntimeInstance instance) {
    if (instance is null)
      return;

    synchronized (_lock) {
      _instances[instance.instanceId] = instance;
    }
  }

  protected AGTDevice[UUID] _devices;
  AGTDevice[] devices() {
    synchronized (_lock) {
      return _devices.values;
    }
  }

  AGTDevice device(UUID deviceId) {
    synchronized (_lock) {
      return _devices.get(deviceId, null);
    }
  }

  void device(AGTDevice device) {
    if (device is null)
      return;

    synchronized (_lock) {
      _devices[device.deviceId] = device;
    }
  }

  protected AGTBackendSystem[UUID] _backends;
  AGTBackendSystem[] backends() {
    synchronized (_lock) {
      return _backends.values;
    }
  }

  AGTBackendSystem backend(UUID backendId) {
    synchronized (_lock) {
      return _backends.get(backendId, null);
    }
  }

  void backend(AGTBackendSystem backend) {
    if (backend is null)
      return;

    synchronized (_lock) {
      _backends[backend.backendId] = backend;
    }
  }
}
