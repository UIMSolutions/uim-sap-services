/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.dst.store;

import uim.sap.dst;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// DSTStore – in-memory multi-tenant store for Destination entities
// ---------------------------------------------------------------------------
class DSTStore : SAPStore {
  private DSTDestination[string] _destinations; // key: tenantId::name
  private DSTCertificate[string] _certificates; // key: tenantId::name
  private DSTAuditLog[string] _logs;
  private long _counter = 0;

  // -----------------------------------------------------------------------
  // ID / key helpers
  // -----------------------------------------------------------------------
  string nextId(string prefix) {
    _counter += 1;
    return prefix ~ "-" ~ to!string(_counter);
  }

  private static string tp(UUID tenantId) {
    return tenantId ~ "::";
  }

  private static string key(UUID tenantId, string name) {
    return tenantId ~ "::" ~ name;
  }

  // -----------------------------------------------------------------------
  // Destinations
  // -----------------------------------------------------------------------
  DSTDestination upsertDestination(DSTDestination item) {
    _destinations[key(item.tenantId, item.name)] = item;
    return item;
  }

  DSTDestination[] listDestinations(UUID tenantId) {
    DSTDestination[] items;
    auto prefix = tp(tenantId);
    foreach (k, v; _destinations)
      if (k.startsWith(prefix))
        items ~= v;
    return items;
  }

  /// Filter destinations by protocol or proxyType
  DSTDestination[] filterDestinations(UUID tenantId, string protocol, string proxyType) {
    DSTDestination[] items;
    auto prefix = tp(tenantId);
    foreach (k, v; _destinations) {
      if (!k.startsWith(prefix))
        continue;
      if (protocol.length > 0 && v.protocol != protocol)
        continue;
      if (proxyType.length > 0 && v.proxyType != proxyType)
        continue;
      items ~= v;
    }
    return items;
  }

  bool tryGetDestination(UUID tenantId, string name, out DSTDestination dest) {
    auto k = key(tenantId, name);
    if (k in _destinations) {
      dest = _destinations[k];
      return true;
    }
    return false;
  }

  bool removeDestination(UUID tenantId, string name) {
    auto k = key(tenantId, name);
    if (k in _destinations) {
      _destinations.remove(k);
      return true;
    }
    return false;
  }

  // -----------------------------------------------------------------------
  // Certificates
  // -----------------------------------------------------------------------
  DSTCertificate upsertCertificate(DSTCertificate item) {
    _certificates[key(item.tenantId, item.name)] = item;
    return item;
  }

  DSTCertificate[] listCertificates(UUID tenantId) {
    DSTCertificate[] items;
    auto prefix = tp(tenantId);
    foreach (k, v; _certificates)
      if (k.startsWith(prefix))
        items ~= v;
    return items;
  }

  bool tryGetCertificate(UUID tenantId, string name, out DSTCertificate cert) {
    auto k = key(tenantId, name);
    if (k in _certificates) {
      cert = _certificates[k];
      return true;
    }
    return false;
  }

  bool removeCertificate(UUID tenantId, string name) {
    auto k = key(tenantId, name);
    if (k in _certificates) {
      _certificates.remove(k);
      return true;
    }
    return false;
  }

  // -----------------------------------------------------------------------
  // Audit Logs
  // -----------------------------------------------------------------------
  DSTAuditLog upsertLog(DSTAuditLog item) {
    _logs[key(item.tenantId, item.logId)] = item;
    return item;
  }

  DSTAuditLog[] listLogs(UUID tenantId) {
    DSTAuditLog[] items;
    auto prefix = tp(tenantId);
    foreach (k, v; _logs)
      if (k.startsWith(prefix))
        items ~= v;
    items.sort!((a, b) => a.timestamp < b.timestamp);
    return items.array;
  }

  DSTAuditLog[] listLogsByDestination(UUID tenantId, string destName) {
    DSTAuditLog[] items;
    auto prefix = tp(tenantId);
    foreach (k, v; _logs)
      if (k.startsWith(prefix) && v.destinationName == destName)
        items ~= v;
    items.sort!((a, b) => a.timestamp < b.timestamp);
    return items.array;
  }
}
