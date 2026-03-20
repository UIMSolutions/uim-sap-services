module uim.sap.cre.store;

import core.sync.mutex : Mutex;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

/** 
  * In-memory implementation of the credential store. This is not thread-safe and should only be used for testing or single-threaded applications.
  * For production use, consider implementing a persistent store (e.g., using a database) and ensuring thread safety.
  *
  * Note: The store does not implement any encryption or security measures. In a real implementation, sensitive data should be encrypted at rest and in transit.
  *
  * The store provides basic CRUD operations for service instances, credentials, and service keys. It uses composite keys to manage relationships between instances and their associated credentials and service keys.
  *
  * Example usage:
  * CREStore store = new CREStore();
  * CREServiceInstance instance = store.upsertInstance(CREServiceInstance(instanceId: "instance1", serviceId: "service1", planId: "plan1"));
  * CRECredential credential = store.upsertCredential(CRECredential(instanceId: "instance1", name: "credential1", secret: encryptedPayload));
  * CREServiceKey serviceKey = store.upsertServiceKey(CREServiceKey(instanceId: "instance1", keyId: "key1", secret: encryptedPayload));
  *
  * The store also provides methods to retrieve and delete instances, credentials, and service keys, as well as to list all instances or all credentials for a given instance.
  *
  * Note: This implementation is purely in-memory and does not persist data across application restarts. For a production implementation, consider using a database or other persistent storage mechanism.
  *
  * Thread safety is achieved using a mutex to synchronize access to the internal data structures. However, this may not be sufficient for high-concurrency scenarios, and a more robust solution may be needed for production use.
  *
  * The store does not implement any access control or authentication mechanisms. In a real implementation, consider adding appropriate security measures to protect sensitive data and restrict access to authorized users.
  *
  * The store is designed to be simple and easy to use for testing and development purposes. It provides a basic interface for managing service instances, credentials, and service keys, but it may not be suitable for production use without additional features and security measures.
  *
  * The store is implemented as a class with methods for each operation. It uses associative arrays (dictionaries) to store instances, credentials, and service keys, with composite keys to manage relationships between them.
  * The store provides methods to upsert (insert or update) instances, credentials, and service keys, as well as to delete and retrieve them. It also provides methods to list all instances or all credentials for a given instance.
  * The store is designed to be simple and easy to use for testing and development purposes, but it may not be suitable for production use without additional features and security measures.
  * The store does not implement any encryption or security measures. In a real implementation, sensitive data should be encrypted at rest and in transit, and appropriate access control and authentication mechanisms should be implemented to protect sensitive data and restrict access to authorized users.
  * The store is implemented as a class with methods for each operation. It uses associative arrays (dictionaries) to store instances, credentials, and service keys, with composite keys to manage relationships between them. The store provides methods to upsert (insert or update) instances, credentials, and service keys, as well as to delete and retrieve them. It
  * 
  * Fields:
  * - CREServiceInstance[string] _instances: A dictionary to store service instances, keyed by instance ID.
  * - CRECredential[string] _credentials: A dictionary to store credentials, keyed by a composite key of instance ID and credential name.
  * - CREServiceKey[string] _serviceKeys: A dictionary to store service keys, keyed by a composite key of instance ID and key ID.
  * - Mutex _lock: A mutex to synchronize access to the internal data structures and ensure thread safety.
  *
  * Methods:
  * - CREServiceInstance upsertInstance(CREServiceInstance instance): Inserts or updates a service instance in the store and returns the instance.
  * - bool deleteInstance(UUID instanceId): Deletes a service instance from the store by its ID and returns true if the instance was deleted, or false if the instance was not found.
  * - bool hasInstance(UUID instanceId): Checks if a service instance exists in the store by its ID and returns true if it exists, or false if it does not exist.
  * - CREServiceInstance getInstance(UUID instanceId): Retrieves a service instance from the store by its ID and returns the instance, or an empty instance if not found
  * - CREServiceInstance[] listInstances(): Lists all service instances in the store and returns an array of instances.
  * - CRECredential upsertCredential(CRECredential credential): Inserts or updates a credential in the store and returns the credential.
  * - bool deleteCredential(UUID instanceId, string name): Deletes a credential from the store by its instance ID and name, and returns true if the credential was deleted, or false if the credential was not found.
  * - CRECredential getCredential(UUID instanceId, string name): Retrieves a credential from the store by its instance ID and name, and returns the credential, or an empty credential if not found.
  * - CRECredential[] listCredentials(UUID instanceId): Lists all credentials for a given service instance ID in the store and returns an array of credentials.
  * - CREServiceKey upsertServiceKey(CREServiceKey key): Inserts or updates a service key in the store and returns the service key.
  * - bool deleteServiceKey(UUID instanceId, string keyId): Deletes a service key from the store by its instance ID and key ID, and returns true if the service key was deleted, or false if the service key was not found.
  * - CREServiceKey getServiceKey(UUID instanceId, string keyId): Retrieves a service key from the store by its instance ID and key ID, and returns the service key   
  * - string compositeKey(string a, string b): A helper method to generate a composite key from two strings (e.g., instance ID and credential name) for use in the dictionaries.
  *
  * Note: This implementation is purely in-memory and does not persist data across application restarts. For a production implementation, consider using a database or other persistent storage mechanism. Thread safety is achieved using a mutex to synchronize access to the internal data structures, but this may not be sufficient for high-concurrency scenarios, and a more robust solution may be needed for production use. The store does not implement any access control or authentication mechanisms, so appropriate security measures should be implemented in a real implementation to protect sensitive data and restrict access to authorized users.
  */

class CREStore : SAPStore {
  private CREServiceInstance[UUID] _instances;
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

  bool deleteInstance(UUID instanceId) {
    synchronized (_lock) {
      if ((instanceId in _instances) is null) {
        return false;
      }
      _instances.remove(instanceId);

      string[] credentialKeys;
      // Remove associated credentials
      foreach (key; _credentials.keys) {
        if (key.length > instanceId.toString().length + 1 && key[0 .. instanceId.toString().length] == instanceId.toString() && key[instanceId.toString().length] == ':') {
          credentialKeys ~= key;
        }
      }
      foreach (key; credentialKeys) {
        _credentials.remove(key);
      }

      string[] serviceKeyKeys;
      foreach (key; _serviceKeys.keys) {
        if (key.length > instanceId.toString().length + 1 && key[0 .. instanceId.toString().length] == instanceId.toString() && key[instanceId.toString().length] == ':') {
          serviceKeyKeys ~= key;
        }
      }

      foreach (key; serviceKeyKeys) {
        _serviceKeys.remove(key);
      }

      return true;
    }
  }

  bool hasInstance(UUID instanceId) {
    synchronized (_lock) {
      return (instanceId in _instances) !is null;
    }
  }

  CREServiceInstance getInstance(UUID instanceId) {
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

  bool deleteCredential(UUID instanceId, string name) {
    synchronized (_lock) {
      auto key = compositeKey(instanceId, name);
      if ((key in _credentials) is null) {
        return false;
      }
      _credentials.remove(key);
      return true;
    }
  }

  CRECredential getCredential(UUID instanceId, string name) {
    synchronized (_lock) {
      auto key = compositeKey(instanceId, name);
      if (auto credential = key in _credentials) {
        return *credential;
      }
    }
    return CRECredential.init;
  }

  CRECredential[] listCredentials(UUID instanceId) {
    CRECredential[] values;
    synchronized (_lock) {
      foreach (key, value; _credentials) {
        if (key.length > instanceId.toString().length + 1 && key[0 .. instanceId.toString().length] == instanceId.toString() && key[instanceId.toString().length] == ':') {
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

  bool deleteServiceKey(UUID instanceId, string keyId) {
    synchronized (_lock) {
      auto key = compositeKey(instanceId, keyId);
      if ((key in _serviceKeys) is null) {
        return false;
      }
      _serviceKeys.remove(key);
      return true;
    }
  }

  CREServiceKey getServiceKey(UUID instanceId, UUID keyId) {
    synchronized (_lock) {
      auto key = compositeKey(instanceId, keyId);
      if (auto serviceKey = key in _serviceKeys) {
        return _serviceKeys[key];
      }
    }
    return null;
  }

}
