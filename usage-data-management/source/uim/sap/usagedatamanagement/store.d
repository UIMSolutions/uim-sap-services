module uim.sap.usagedatamanagement.store;

import core.sync.mutex : Mutex;

import uim.sap.usagedatamanagement;

mixin(ShowModule!());

@safe:

class UDMStore : SAPStore {
  private UsageEvent[string][] _eventsByTenant;
  private Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  UsageEvent appendEvent(UsageEvent eventItem) {
    synchronized (_lock) {
      _eventsByTenant[eventItem.tenantId] ~= eventItem;
      return eventItem;
    }
  }

  UsageEvent[] listEvents(string tenantId) {
    synchronized (_lock) {
      if (auto values = tenantId in _eventsByTenant) {
        return (*values).dup;
      }
    }
    return [];
  }

  long countEvents(string tenantId = "") {
    synchronized (_lock) {
      if (tenantId.length > 0) {
        if (auto values = tenantId in _eventsByTenant) {
          return cast(long)values.length;
        }
        return 0;
      }

      long count = 0;
      foreach (_, values; _eventsByTenant) {
        count += cast(long)values.length;
      }
      return count;
    }
  }

  string[] listTenants() {
    string[] tenants;
    synchronized (_lock) {
      foreach (tenantId, _; _eventsByTenant) {
        tenants ~= tenantId;
      }
    }
    return tenants;
  }
}
