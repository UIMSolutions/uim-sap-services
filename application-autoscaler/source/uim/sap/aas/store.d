/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aas.store;

import core.sync.mutex : Mutex;

import uim.sap.aas;
@safe:

/**
  * AASStore is a simple in-memory store for AAS resources. It is not thread-safe and should only be used for testing and development purposes.
  *
  * In a production environment, a more robust and scalable storage solution should be used, such as a database or a distributed cache.
  *
  * The AASStore provides basic CRUD operations for AASApp and AASScalingPolicy resources. It uses a simple map to store the resources, keyed by their IDs.
  * The store also provides a mutex to synchronize access to the resources, but it is not designed for high concurrency or performance.
  *
  * Note: This implementation is intended for demonstration purposes only and should not be used in a production environment. It does not provide any durability, replication, or backup capabilities, and it may lose data if the application is restarted or if there are concurrent modifications to the store.
  *
  * For a production implementation, consider using a database or a distributed cache that provides durability, replication, and backup capabilities. Additionally, consider implementing proper locking and concurrency control mechanisms to ensure data integrity and consistency in a multi-threaded environment.
  */
class AASStore : SAPStore {
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
                return _apps[appId];
            }
        }
        return null;
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
        return null;
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
        return null;
    }
}
