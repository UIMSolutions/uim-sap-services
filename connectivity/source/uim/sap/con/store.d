/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.con.store;

import core.sync.mutex : Mutex;

import uim.sap.con;

mixin(ShowModule!());

@safe:

class CONStore : SAPStore {
  mixin(SAPStoreTemplate!CONStore);

  protected CONDestination[string] _destinations;

  CONDestination upsertDestination(CONDestination destination) {
    synchronized (_lock) {
      auto key = compositeKey(destination.tenantId, destination.name);
      if (key in _destinations) {
        destination.createdAt = _destinations[key].createdAt;
      }
      _destinations[key] = destination;
      return destination;
    }
  }

  bool deleteDestination(UUID tenantId, string name) {
    synchronized (_lock) {
      auto key = compositeKey(tenantId, name);
      if (key !in _destinations) {
        return false;
      }
      _destinations.remove(key);
      return true;
    }
  }

  CONDestination getDestination(UUID tenantId, string name) {
    synchronized (_lock) {
      auto key = compositeKey(tenantId, name);
      if (key in _destinations) {
        return _destinations[key];
      }
    }
    auto missing = new CONDestination();
    missing.tenantId = tenantId;
    return missing;
  }

  CONDestination[] listDestinations(UUID tenantId) {
    synchronized (_lock) {
      _destinations.byKeyValue(kv => startsWithTenant(kv.key, tenantId)).map!(kv => kv.value).array;
    }
  }

  CONDestination[] listCloudDatabases(UUID tenantId) {
    synchronized (_lock) {
      return _destinations.byKeyValue(kv => startsWithTenant(kv.key, tenantId) && kv
          .value.cloudDatabase).map!(kv => kv.value).array;
    }
  }

  UUID[] listTenantIds() {
    UUID[] ids;
    synchronized (_lock) {
      foreach (key; _destinations.keys) {
        auto separator = indexOfSeparator(key);
        if (separator > 0) {
          auto tenantId = UUID(key[0 .. separator]);
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

  size_t countDestinations(UUID tenantId) {
    synchronized (_lock) {
      return _destinations.keys.filter!(key => startsWithTenant(key, tenantId)).array.length;
    }
  }
}
///
unittest {
  import std.stdio;
  import std.uuid : randomUUID;

  auto store = new CONStore();
  auto tenantId = randomUUID();
  // Test creating a destination
  auto dest1 = CONDestination(tenantId, "Destination1",// "targetPath" is optional and should default to "/" if not provided
    "http://example.com/api",// "onPremise" is optional and should default to true if not provided
    false);
  auto dest2 = CONDestination(tenantId, "Destination2", "http://example.com/api2", true);

  assert(store.listDestinations(tenantId).length == 0);
  assert(store.upsertDestination(dest1).name == "Destination1");
  assert(store.upsertDestination(dest2).name == "Destination2");
  assert(store.listDestinations(tenantId).length == 2);
  assert(store.getDestination(tenantId, "Destination1").name == "Destination1");
  assert(store.deleteDestination(tenantId, "Destination1") == true);
  assert(store.getDestination(tenantId, "Destination1").name.length == 0);
  assert(store.listDestinations(tenantId).length == 1);
}
