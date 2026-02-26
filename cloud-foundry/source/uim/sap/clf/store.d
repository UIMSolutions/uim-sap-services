/**
 * In-memory store for CLF resources
 */
module uim.sap.clf.store;

import core.sync.mutex : Mutex;
import uim.sap.clf;

mixin(ShowModule!());

@safe:

class CLFStore {
  private CLFOrg[string] _orgs;
  private CLFSpace[string] _spaces;
  private CLFApp[string] _apps;
  private CLFServiceOffering[string] _serviceOfferings;
  private CLFServiceInstance[string] _serviceInstances;
  private Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  void seedServiceOfferings() {
    synchronized (_lock) {
      if (_serviceOfferings.length > 0) {
        return;
      }

      CLFServiceOffering xsuaa;
      xsuaa.guid = "service-xsuaa";
      xsuaa.label = "xsuaa";
      xsuaa.provider = "SAP";
      xsuaa.description = "Authorization and trust management";
      _serviceOfferings[xsuaa.guid] = xsuaa;

      CLFServiceOffering hana;
      hana.guid = "service-hana";
      hana.label = "hana";
      hana.provider = "SAP";
      hana.description = "SAP HANA database service";
      _serviceOfferings[hana.guid] = hana;

      CLFServiceOffering destination;
      destination.guid = "service-destination";
      destination.label = "destination";
      destination.provider = "SAP";
      destination.description = "Destination service";
      _serviceOfferings[destination.guid] = destination;
    }
  }

  CLFOrg createOrg(CLFOrg org) {
    synchronized (_lock) {
      _orgs[org.guid] = org;
      return org;
    }
  }

  CLFSpace createSpace(CLFSpace space) {
    synchronized (_lock) {
      _spaces[space.guid] = space;
      return space;
    }
  }

  CLFApp createApp(CLFApp app) {
    synchronized (_lock) {
      _apps[app.guid] = app;
      return app;
    }
  }

  CLFServiceInstance createServiceInstance(CLFServiceInstance instance) {
    synchronized (_lock) {
      _serviceInstances[instance.guid] = instance;
      return instance;
    }
  }

  CLFOrg[] listOrgs() {
    CLFOrg[] values;
    synchronized (_lock) {
      foreach (item; _orgs.byValue) {
        values ~= item;
      }
    }
    return values;
  }

  CLFSpace[] listSpaces() {
    CLFSpace[] values;
    synchronized (_lock) {
      foreach (item; _spaces.byValue) {
        values ~= item;
      }
    }
    return values;
  }

  CLFApp[] listApps() {
    CLFApp[] values;
    synchronized (_lock) {
      foreach (item; _apps.byValue) {
        values ~= item;
      }
    }
    return values;
  }

  CLFServiceOffering[] listServiceOfferings() {
    CLFServiceOffering[] values;
    synchronized (_lock) {
      foreach (item; _serviceOfferings.byValue) {
        values ~= item;
      }
    }
    return values;
  }

  CLFServiceInstance[] listServiceInstances() {
    CLFServiceInstance[] values;
    synchronized (_lock) {
      foreach (item; _serviceInstances.byValue) {
        values ~= item;
      }
    }
    return values;
  }

  bool hasOrg(string guid) {
    synchronized (_lock) {
      return (guid in _orgs) !is null;
    }
  }

  bool hasSpace(string guid) {
    synchronized (_lock) {
      return (guid in _spaces) !is null;
    }
  }

  bool hasServiceOffering(string guid) {
    synchronized (_lock) {
      return (guid in _serviceOfferings) !is null;
    }
  }

  CLFApp getApp(string guid) {
    synchronized (_lock) {
      if (auto ptr = guid in _apps) {
        return *ptr;
      }
    }
    return CLFApp.init;
  }
}
