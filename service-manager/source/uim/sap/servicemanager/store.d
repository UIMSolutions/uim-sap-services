module uim.sap.servicemanager.store;

import core.sync.mutex : Mutex;

import uim.sap.servicemanager;

mixin(ShowModule!());

@safe:

class SVMStore : SAPStore {
  private SVMPlatform[string] _platforms;
  private SVMServiceInstance[string] _instances;
  private SVMServiceBinding[string] _bindings;
  private Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  SVMPlatform upsertPlatform(SVMPlatform platform) {
    synchronized (_lock) {
      _platforms[scopedKey(platform.tenantId, "platform", platform.platformId)] = platform;
      return platform;
    }
  }

  SVMPlatform[] listPlatforms(UUID tenantId) {
    SVMPlatform[] values;
    synchronized (_lock) {
      foreach (key, value; _platforms) {
        if (belongsTo(key, tenantId)) {
          values ~= value;
        }
      }
    }
    return values;
  }

  SVMPlatform getPlatform(UUID tenantId, string platformId) {
    synchronized (_lock) {
      auto key = scopedKey(tenantId, "platform", platformId);
      if (auto value = key in _platforms) {
        return *value;
      }
    }
    return SVMPlatform.init;
  }

  bool deletePlatform(UUID tenantId, string platformId) {
    synchronized (_lock) {
      auto key = scopedKey(tenantId, "platform", platformId);
      if ((key in _platforms) is null) {
        return false;
      }
      _platforms.remove(key);
      return true;
    }
  }

  SVMServiceInstance upsertInstance(SVMServiceInstance instanceItem) {
    synchronized (_lock) {
      auto key = scopedKey(instanceItem.tenantId, "instance", instanceItem.instanceId);
      if (auto existing = key in _instances) {
        instanceItem.createdAt = existing.createdAt;
      }
      _instances[key] = instanceItem;
      return instanceItem;
    }
  }

  SVMServiceInstance[] listInstances(UUID tenantId) {
    SVMServiceInstance[] values;
    synchronized (_lock) {
      foreach (key, value; _instances) {
        if (belongsTo(key, tenantId)) {
          values ~= value;
        }
      }
    }
    return values;
  }

  SVMServiceInstance getInstance(UUID tenantId, UUID instanceId) {
    synchronized (_lock) {
      auto key = scopedKey(tenantId, "instance", instanceId);
      if (auto value = key in _instances) {
        return *value;
      }
    }
    return SVMServiceInstance.init;
  }

  bool deleteInstance(UUID tenantId, UUID instanceId) {
    synchronized (_lock) {
      auto key = scopedKey(tenantId, "instance", instanceId);
      if ((key in _instances) is null) {
        return false;
      }
      _instances.remove(key);
      return true;
    }
  }

  SVMServiceBinding upsertBinding(SVMServiceBinding binding) {
    synchronized (_lock) {
      _bindings[scopedKey(binding.tenantId, "binding", binding.bindingId)] = binding;
      return binding;
    }
  }

  SVMServiceBinding[] listBindings(UUID tenantId) {
    SVMServiceBinding[] values;
    synchronized (_lock) {
      foreach (key, value; _bindings) {
        if (belongsTo(key, tenantId)) {
          values ~= value;
        }
      }
    }
    return values;
  }

  bool deleteBinding(UUID tenantId, string bindingId) {
    synchronized (_lock) {
      auto key = scopedKey(tenantId, "binding", bindingId);
      if ((key in _bindings) is null) {
        return false;
      }
      _bindings.remove(key);
      return true;
    }
  }

  private string scopedKey(UUID tenantId, string scopePart, string id) {
    return tenantId ~ ":" ~ scopePart ~ ":" ~ id;
  }

  private bool belongsTo(string key, UUID tenantId) {
    return key.length > tenantId.length + 1 && key[0 .. tenantId.length] == tenantId && key[tenantId.length] == ':';
  }
}
