module uim.sap.con.store;

import core.sync.mutex : Mutex;

import uim.sap.con.models;

class CONStore : SAPStore {
    private CONDestination[string] _destinations;
    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    CONDestination upsertDestination(CONDestination destination) {
        synchronized (_lock) {
            auto key = compositeKey(destination.tenantId, destination.name);
            if (auto existing = key in _destinations) {
                destination.createdAt = existing.createdAt;
            }
            _destinations[key] = destination;
            return destination;
        }
    }

    bool deleteDestination(string tenantId, string name) {
        synchronized (_lock) {
            auto key = compositeKey(tenantId, name);
            if ((key in _destinations) is null) {
                return false;
            }
            _destinations.remove(key);
            return true;
        }
    }

    CONDestination getDestination(string tenantId, string name) {
        synchronized (_lock) {
            auto key = compositeKey(tenantId, name);
            if (auto destination = key in _destinations) {
                return *destination;
            }
        }
        return CONDestination.init;
    }

    CONDestination[] listDestinations(string tenantId) {
        CONDestination[] values;
        synchronized (_lock) {
            foreach (key, destination; _destinations) {
                if (startsWithTenant(key, tenantId)) {
                    values ~= destination;
                }
            }
        }
        return values;
    }

    CONDestination[] listCloudDatabases(string tenantId) {
        CONDestination[] values;
        synchronized (_lock) {
            foreach (key, destination; _destinations) {
                if (startsWithTenant(key, tenantId) && destination.cloudDatabase) {
                    values ~= destination;
                }
            }
        }
        return values;
    }

    string[] listTenantIds() {
        string[] ids;
        synchronized (_lock) {
            foreach (key; _destinations.keys) {
                auto separator = indexOfSeparator(key);
                if (separator > 0) {
                    auto tenantId = key[0 .. separator];
                    if (!containsTenant(ids, tenantId)) {
                        ids ~= tenantId;
                    }
                }
            }
        }
        return ids;
    }

    size_t countDestinations() {
        synchronized (_lock) {
            return _destinations.length;
        }
    }

    size_t countDestinations(string tenantId) {
        size_t total;
        synchronized (_lock) {
            foreach (key; _destinations.keys) {
                if (startsWithTenant(key, tenantId)) {
                    ++total;
                }
            }
        }
        return total;
    }

    private string compositeKey(string tenantId, string destinationName) {
        return tenantId ~ ":" ~ destinationName;
    }

    private bool startsWithTenant(string key, string tenantId) {
        return key.length > tenantId.length + 1 && key[0 .. tenantId.length] == tenantId && key[tenantId.length] == ':';
    }

    private size_t indexOfSeparator(string key) {
        foreach (i, c; key) {
            if (c == ':') {
                return i;
            }
        }
        return 0;
    }

    private bool containsTenant(string[] values, string tenantId) {
        foreach (value; values) {
            if (value == tenantId) {
                return true;
            }
        }
        return false;
    }
}
