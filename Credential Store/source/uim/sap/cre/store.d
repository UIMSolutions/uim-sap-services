module uim.sap.cre.store;

import core.sync.mutex : Mutex;

import uim.sap.cre.models;

class CREStore {
    private CREServiceInstance[string] _instances;
    private CRECredential[string] _credentials;
    private CREServiceKey[string] _serviceKeys;
    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    CREServiceInstance upsertInstance(CREServiceInstance instance) {
        synchronized (_lock) {
            if (auto existing = instance.instanceId in _instances) {
                instance.createdAt = existing.createdAt;
            }
            _instances[instance.instanceId] = instance;
            return instance;
        }
    }

    bool deleteInstance(string instanceId) {
        synchronized (_lock) {
            if ((instanceId in _instances) is null) {
                return false;
            }
            _instances.remove(instanceId);

            string[] credentialKeys;
            foreach (key; _credentials.keys) {
                if (key.length > instanceId.length + 1 && key[0 .. instanceId.length] == instanceId && key[instanceId.length] == ':') {
                    credentialKeys ~= key;
                }
            }
            foreach (key; credentialKeys) {
                _credentials.remove(key);
            }

            string[] serviceKeyKeys;
            foreach (key; _serviceKeys.keys) {
                if (key.length > instanceId.length + 1 && key[0 .. instanceId.length] == instanceId && key[instanceId.length] == ':') {
                    serviceKeyKeys ~= key;
                }
            }
            foreach (key; serviceKeyKeys) {
                _serviceKeys.remove(key);
            }
            return true;
        }
    }

    bool hasInstance(string instanceId) {
        synchronized (_lock) {
            return (instanceId in _instances) !is null;
        }
    }

    CREServiceInstance getInstance(string instanceId) {
        synchronized (_lock) {
            if (auto instance = instanceId in _instances) {
                return *instance;
            }
        }
        return CREServiceInstance.init;
    }

    CREServiceInstance[] listInstances() {
        CREServiceInstance[] values;
        synchronized (_lock) {
            foreach (item; _instances.byValue) {
                values ~= item;
            }
        }
        return values;
    }

    CRECredential upsertCredential(CRECredential credential) {
        synchronized (_lock) {
            auto key = compositeKey(credential.instanceId, credential.name);
            if (auto existing = key in _credentials) {
                credential.createdAt = existing.createdAt;
            }
            _credentials[key] = credential;
            return credential;
        }
    }

    bool deleteCredential(string instanceId, string name) {
        synchronized (_lock) {
            auto key = compositeKey(instanceId, name);
            if ((key in _credentials) is null) {
                return false;
            }
            _credentials.remove(key);
            return true;
        }
    }

    CRECredential getCredential(string instanceId, string name) {
        synchronized (_lock) {
            auto key = compositeKey(instanceId, name);
            if (auto credential = key in _credentials) {
                return *credential;
            }
        }
        return CRECredential.init;
    }

    CRECredential[] listCredentials(string instanceId) {
        CRECredential[] values;
        synchronized (_lock) {
            foreach (key, value; _credentials) {
                if (key.length > instanceId.length + 1 && key[0 .. instanceId.length] == instanceId && key[instanceId.length] == ':') {
                    values ~= value;
                }
            }
        }
        return values;
    }

    CREServiceKey upsertServiceKey(CREServiceKey key) {
        synchronized (_lock) {
            auto composite = compositeKey(key.instanceId, key.keyId);
            _serviceKeys[composite] = key;
            return key;
        }
    }

    bool deleteServiceKey(string instanceId, string keyId) {
        synchronized (_lock) {
            auto key = compositeKey(instanceId, keyId);
            if ((key in _serviceKeys) is null) {
                return false;
            }
            _serviceKeys.remove(key);
            return true;
        }
    }

    CREServiceKey getServiceKey(string instanceId, string keyId) {
        synchronized (_lock) {
            auto key = compositeKey(instanceId, keyId);
            if (auto serviceKey = key in _serviceKeys) {
                return *serviceKey;
            }
        }
        return CREServiceKey.init;
    }

    private string compositeKey(string a, string b) {
        return a ~ ":" ~ b;
    }
}
