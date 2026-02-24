/**
 * In-memory store for AAS resources
 */
module uim.sap.aas.store;

import core.sync.mutex : Mutex;

import uim.sap.aas.models;

class AASStore {
    private AASApp[string] _apps;
    private AASScalingPolicy[][string] _policiesByApp;
    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    AASApp createApp(AASApp app) {
        synchronized (_lock) {
            _apps[app.id] = app;
            return app;
        }
    }

    AASApp updateAppInstances(string appId, uint desiredInstances) {
        synchronized (_lock) {
            if (auto ptr = appId in _apps) {
                ptr.currentInstances = desiredInstances;
                return *ptr;
            }
        }
        return AASApp.init;
    }

    AASApp[] listApps() {
        AASApp[] values;
        synchronized (_lock) {
            foreach (entry; _apps.byValue) {
                values ~= entry;
            }
        }
        return values;
    }

    AASApp getApp(string appId) {
        synchronized (_lock) {
            if (auto ptr = appId in _apps) {
                return *ptr;
            }
        }
        return AASApp.init;
    }

    bool hasApp(string appId) {
        synchronized (_lock) {
            return (appId in _apps) !is null;
        }
    }

    AASScalingPolicy createPolicy(AASScalingPolicy policy) {
        synchronized (_lock) {
            _policiesByApp[policy.appId] ~= policy;
            return policy;
        }
    }

    AASScalingPolicy[] listPolicies(string appId) {
        synchronized (_lock) {
            if (auto ptr = appId in _policiesByApp) {
                return (*ptr).dup;
            }
        }
        return [];
    }
}
