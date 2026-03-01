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
class AgentryStore : SAPStore {
    private AgentryMobileApp[string] _apps;
    private AgentryAppVersion[][string] _versionsByApp;
    private AgentryTestRun[][string] _testRunsByApp;
    private AgentryRuntimeInstance[string] _instances;
    private AgentryDevice[string] _devices;
    private AgentryBackendSystem[string] _backends;

    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    AgentryMobileApp upsertApp(AgentryMobileApp app) {
        synchronized (_lock) {
            auto key = appKey(app.tenantId, app.appId);
            if (auto existing = key in _apps) {
                app.createdAt = existing.createdAt;
            }
            _apps[key] = app;
            return app;
        }
    }

    AgentryMobileApp getApp(string tenantId, string appId) {
        synchronized (_lock) {
            auto key = appKey(tenantId, appId);
            if (auto value = key in _apps) {
                return *value;
            }
        }
        return AgentryMobileApp.init;
    }

    AgentryMobileApp[] listApps(string tenantId) {
        AgentryMobileApp[] list;
        synchronized (_lock) {
            foreach (key, app; _apps) {
                if (belongsToTenant(key, tenantId)) {
                    list ~= app;
                }
            }
        }
        return list;
    }

    AgentryAppVersion addVersion(AgentryAppVersion appVersion) {
        synchronized (_lock) {
            auto key = appKey(appVersion.tenantId, appVersion.appId);
            _versionsByApp[key] ~= appVersion;
            return appVersion;
        }
    }

    AgentryAppVersion[] listVersions(string tenantId, string appId) {
        synchronized (_lock) {
            auto key = appKey(tenantId, appId);
            if (auto list = key in _versionsByApp) {
                return (*list).dup;
            }
        }
        return [];
    }

    AgentryTestRun addTestRun(AgentryTestRun testRun) {
        synchronized (_lock) {
            auto key = appKey(testRun.tenantId, testRun.appId);
            _testRunsByApp[key] ~= testRun;
            return testRun;
        }
    }

    AgentryTestRun[] listTestRuns(string tenantId, string appId) {
        synchronized (_lock) {
            auto key = appKey(tenantId, appId);
            if (auto list = key in _testRunsByApp) {
                return (*list).dup;
            }
        }
        return [];
    }

    AgentryRuntimeInstance upsertInstance(AgentryRuntimeInstance instance) {
        synchronized (_lock) {
            auto key = instanceKey(instance.tenantId, instance.instanceId);
            _instances[key] = instance;
            return instance;
        }
    }

    AgentryRuntimeInstance getInstance(string tenantId, string instanceId) {
        synchronized (_lock) {
            auto key = instanceKey(tenantId, instanceId);
            if (auto value = key in _instances) {
                return *value;
            }
        }
        return AgentryRuntimeInstance.init;
    }

    AgentryRuntimeInstance[] listInstances(string tenantId) {
        AgentryRuntimeInstance[] list;
        synchronized (_lock) {
            foreach (key, instance; _instances) {
                if (belongsToTenant(key, tenantId)) {
                    list ~= instance;
                }
            }
        }
        return list;
    }

    AgentryDevice upsertDevice(AgentryDevice device) {
        synchronized (_lock) {
            auto key = deviceKey(device.tenantId, device.deviceId);
            _devices[key] = device;
            return device;
        }
    }

    AgentryDevice getDevice(string tenantId, string deviceId) {
        synchronized (_lock) {
            auto key = deviceKey(tenantId, deviceId);
            if (auto value = key in _devices) {
                return *value;
            }
        }
        return AgentryDevice.init;
    }

    AgentryDevice[] listDevices(string tenantId) {
        AgentryDevice[] list;
        synchronized (_lock) {
            foreach (key, device; _devices) {
                if (belongsToTenant(key, tenantId)) {
                    list ~= device;
                }
            }
        }
        return list;
    }

    AgentryBackendSystem upsertBackend(AgentryBackendSystem backend) {
        synchronized (_lock) {
            auto key = backendKey(backend.tenantId, backend.backendId);
            _backends[key] = backend;
            return backend;
        }
    }

    AgentryBackendSystem[] listBackends(string tenantId) {
        AgentryBackendSystem[] list;
        synchronized (_lock) {
            foreach (key, backend; _backends) {
                if (belongsToTenant(key, tenantId)) {
                    list ~= backend;
                }
            }
        }
        return list;
    }

    private string appKey(string tenantId, string appId) {
        return tenantId ~ ":app:" ~ appId;
    }

    private string instanceKey(string tenantId, string instanceId) {
        return tenantId ~ ":instance:" ~ instanceId;
    }

    private string deviceKey(string tenantId, string deviceId) {
        return tenantId ~ ":device:" ~ deviceId;
    }

    private string backendKey(string tenantId, string backendId) {
        return tenantId ~ ":backend:" ~ backendId;
    }

    private bool belongsToTenant(string key, string tenantId) {
        return key.length > tenantId.length + 1
            && key[0 .. tenantId.length] == tenantId
            && key[tenantId.length] == ':';
    }
}
