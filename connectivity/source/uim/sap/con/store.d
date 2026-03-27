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
      if (auto existing = key in _destinations) {
        destination.createdAt = existing.createdAt;
      }
      _destinations[key] = destination;
      return destination;
    }
  }

  bool deleteDestination(UUID tenantId, string name) {
    synchronized (_lock) {
      auto key = compositeKey(tenantId, name);
      if ((key in _destinations) is null) {
        return false;
      }
      _destinations.remove(key);
      return true;
    }
  }

  CONDestination getDestination(UUID tenantId, string name) {
    synchronized (_lock) {
      auto key = compositeKey(tenantId, name);
      if (auto destination = key in _destinations) {
        return *destination;
      }
    }
    return CONDestination.init;
  }

  CONDestination[] listDestinations(UUID tenantId) {
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

  CONDestination[] listCloudDatabases(UUID tenantId) {
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
