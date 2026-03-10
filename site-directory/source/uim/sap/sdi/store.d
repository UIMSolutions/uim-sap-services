/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.sdi.store;

import core.sync.mutex : Mutex;

import uim.sap.sdi;

@safe:

class SDIStore : SAPStore {
  private SDISite[string] _sites;
  private Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  SDISite upsertSite(SDISite site) {
    synchronized (_lock) {
      auto key = scopedKey(site.tenantId, site.siteId);
      if (auto existing = key in _sites)
        site.createdAt = existing.createdAt;
      _sites[key] = site;
      return site;
    }
  }

  SDISite[] listSites(string tenantId) {
    SDISite[] values;
    synchronized (_lock) {
      auto prefix = tenantId ~ ":";
      foreach (key, value; _sites) {
        if (key.length >= prefix.length && key[0 .. prefix.length] == prefix)
          values ~= value;
      }
    }
    return values;
  }

  Nullable!SDISite getSite(string tenantId, string siteId) {
    synchronized (_lock) {
      auto key = scopedKey(tenantId, siteId);
      if (auto value = key in _sites)
        return Nullable!SDISite(*value);
      return Nullable!SDISite.init;
    }
  }

  bool deleteSite(string tenantId, string siteId) {
    synchronized (_lock) {
      auto key = scopedKey(tenantId, siteId);
      if ((key in _sites) is null)
        return false;
      _sites.remove(key);
      return true;
    }
  }

  void setDefaultSite(string tenantId, string siteId) {
    synchronized (_lock) {
      auto prefix = tenantId ~ ":";
      foreach (key, value; _sites) {
        if (key.length >= prefix.length && key[0 .. prefix.length] == prefix) {
          value.isDefault = (value.siteId == siteId);
          _sites[key] = value;
        }
      }
    }
  }

  private string scopedKey(string tenantId, string siteId) {
    return tenantId ~ ":" ~ siteId;
  }
}
