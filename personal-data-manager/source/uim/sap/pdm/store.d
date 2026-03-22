module uim.sap.pdm.store;

import core.sync.mutex : Mutex;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

/**
 * Thread-safe in-memory store for Personal Data Manager.
 *
 * Manages: tenants, data subjects, personal data records,
 * data requests, notifications, and data usage tracking.
 * All keys are tenant-scoped for multitenancy support.
 */
class PDMStore : SAPStore {
  private {
    PDMTenant[string] _tenants; // key: tenantId
    PDMDataSubject[string] _subjects; // key: tenantId/subjectId
    PDMPersonalDataRecord[string] _records; // key: tenantId/recordId
    PDMDataRequest[string] _requests; // key: tenantId/requestId
    PDMNotification[string] _notifications; // key: tenantId/notificationId
    PDMDataUsage[string] _usages; // key: tenantId/usageId
    Mutex _mutex;
  }

  this() {
    _mutex = new Mutex;
  }

  // ──────────────────────────────────────
  //  Tenants
  // ──────────────────────────────────────

  PDMTenant upsertTenant(PDMTenant t) {
    synchronized (_mutex) {
      _tenants[t.tenantId.toString] = t;
      return t;
    }
  }

  PDMTenant getTenant(UUID tenantId) {
    synchronized (_mutex) {
      if (hasTenant(tenantId))
        return _tenants[tenantId.toString];
      return null;
    }
  }

  bool hasTenant(UUID tenantId) {
    synchronized (_mutex) {
      return (tenantId.toString in _tenants) ? true : false;
    }
  }

  PDMTenant[] listTenants() {
    synchronized (_mutex) {
      return _tenants.values;
    }
  }

  bool removeTenant(UUID tenantId) {
    synchronized (_mutex) {
      if (hasTenant(tenantId)) {
        _tenants.remove(tenantId.toString);
        return true;
      }
      return false;
    }
  }

  // ──────────────────────────────────────
  //  Data Subjects
  // ──────────────────────────────────────

  PDMDataSubject upsertSubject(PDMDataSubject s) {
    synchronized (_mutex) {
      string key = tenantKey(s.tenantId, s.subjectId);
      _subjects[key] = s;
      return s;
    }
  }

  PDMDataSubject getSubject(UUID tenantId, UUID subjectId) {
    synchronized (_mutex) {
      string key = tenantKey(tenantId, subjectId);
      if (key in _subjects)
        return _subjects[key];
      return null;
    }
  }

  bool hasSubject(UUID tenantId, UUID subjectId) {
    synchronized (_mutex) {
      string key = tenantKey(tenantId, subjectId);
      return (key in _subjects) ? true : false;
    }
  }

  PDMDataSubject[] listSubjects(UUID tenantId) {
    synchronized (_mutex) {
      return _subjects.byValue.filter!(s => s.tenantId == tenantId).array;
    }
  }

  PDMDataSubject[] searchSubjects(UUID tenantId, string term) {
    synchronized (_mutex) {
      return _subjects.byValue.filter!(subject => subject.tenantId == tenantId && matchesSubject(subject, term)).array;
    }
  }

  PDMDataSubject[] searchSubjectsByType(UUID tenantId, PDMSubjectType subjectType) {
    synchronized (_mutex) {
      return _subjects.byValue.filter!(subject => subject.tenantId == tenantId && subject.subjectType == subjectType).array;
    }
  }

  bool removeSubject(UUID tenantId, UUID subjectId) {
    synchronized (_mutex) {
      string key = tenantKey(tenantId, subjectId);
      if (key in _subjects) {
        _subjects.remove(key);
        return true;
      }
      return false;
    }
  }

  size_t subjectCount(UUID tenantId) {
    synchronized (_mutex) {
      size_t count = 0;
      foreach (ref s; _subjects)
        if (s.tenantId == tenantId)
          count++;
      return count;
    }
  }

  size_t totalSubjectCount() {
    synchronized (_mutex) {
      return _subjects.length;
    }
  }

  // ──────────────────────────────────────
  //  Personal Data Records
  // ──────────────────────────────────────

  PDMPersonalDataRecord upsertRecord(PDMPersonalDataRecord r) {
    synchronized (_mutex) {
      string key = tenantKey(r.tenantId, r.recordId);
      _records[key] = r;
      return r;
    }
  }

  PDMPersonalDataRecord getRecord(UUID tenantId, UUID recordId) {
    synchronized (_mutex) {
      string key = tenantKey(tenantId, recordId);
      if (auto p = key in _records)
        return *p;
      return PDMPersonalDataRecord.init;
    }
  }

  bool hasRecord(UUID tenantId, UUID recordId) {
    synchronized (_mutex) {
      string key = tenantKey(tenantId, recordId);
      if (key in _records)
        return true;
      return false;
    }
  }

  PDMPersonalDataRecord[] listRecordsBySubject(UUID tenantId, UUID subjectId) {
    synchronized (_mutex) {
      PDMPersonalDataRecord[] result;
      foreach (ref r; _records)
        if (r.tenantId == tenantId && r.subjectId == subjectId)
          result ~= r;
      return result;
    }
  }

  bool removeRecord(UUID tenantId, UUID recordId) {
    synchronized (_mutex) {
      string key = tenantKey(tenantId, recordId);
      if (key in _records) {
        _records.remove(key);
        return true;
      }
      return false;
    }
  }

  /// Remove all records for a data subject (erasure)
  size_t removeRecordsBySubject(UUID tenantId, UUID subjectId) {
    synchronized (_mutex) {
      string[] keysToRemove;
      foreach (key, ref r; _records) {
        if (r.tenantId == tenantId && r.subjectId == subjectId)
          keysToRemove ~= key;
      }
      foreach (k; keysToRemove)
        _records.remove(k);
      return keysToRemove.length;
    }
  }

  size_t recordCountBySubject(UUID tenantId, UUID subjectId) {
    synchronized (_mutex) {
      return _records.byValue.filter!(r => r.tenantId == tenantId && r.subjectId == subjectId)
        .array.length;
    }
  }

  // ──────────────────────────────────────
  //  Data Requests
  // ──────────────────────────────────────

  PDMDataRequest upsertRequest(PDMDataRequest r) {
    synchronized (_mutex) {
      string key = tenantKey(r.tenantId, r.requestId);
      _requests[key] = r;
      return r;
    }
  }

  PDMDataRequest getRequest(UUID tenantId, UUID requestId) {
    synchronized (_mutex) {
      string key = tenantKey(tenantId, requestId);
      if (key in _requests)
        return _requests[key];
      return null;
    }
  }

  bool hasRequest(UUID tenantId, UUID requestId) {
    synchronized (_mutex) {
      string key = tenantKey(tenantId, requestId);
      if (key in _requests)
        return true;
      return false;
    }
  }

  PDMDataRequest[] listRequests(UUID tenantId) {
    synchronized (_mutex) {
      return _requests.byValue.filter!(r => r.tenantId == tenantId).array;
    }
  }

  PDMDataRequest[] listRequestsBySubject(UUID tenantId, UUID subjectId) {
    synchronized (_mutex) {
      return _requests.byValue.filter!(r => r.tenantId == tenantId && r.subjectId == subjectId)
        .array;
    }
  }

  PDMDataRequest[] listRequestsByStatus(UUID tenantId, PDMRequestStatus status) {
    synchronized (_mutex) {
      return _requests.byValue.filter!(r => r.tenantId == tenantId && r.status == status).array;
    }
  }

  size_t requestCount(UUID tenantId) {
    synchronized (_mutex) {
      return _requests.byValue.filter!(r => r.tenantId == tenantId).array.length;
    }
  }

  size_t totalRequestCount() {
    synchronized (_mutex) {
      return _requests.length;
    }
  }

  // ──────────────────────────────────────
  //  Notifications
  // ──────────────────────────────────────

  PDMNotification storeNotification(PDMNotification n) {
    synchronized (_mutex) {
      string key = tenantKey(n.tenantId, n.notificationId);
      _notifications[key] = n;
      return n;
    }
  }

  PDMNotification getNotification(UUID tenantId, UUID notificationId) {
    synchronized (_mutex) {
      string key = tenantKey(tenantId, notificationId);
      if (key in _notifications)
        return _notifications[key];
      return null;
    }
  }

  PDMNotification[] listNotificationsBySubject(UUID tenantId, UUID subjectId) {
    synchronized (_mutex) {
      return _notifications.byValue.filter!(n => n.tenantId == tenantId && n.subjectId == subjectId)
        .array;
    }
  }

  bool updateNotificationStatus(UUID tenantId, UUID notificationId, PDMNotificationStatus status) {
    synchronized (_mutex) {
      string key = tenantKey(tenantId, notificationId);
      if (key in _notifications) {
        _notifications[key].status = status;
        if (status == PDMNotificationStatus.sent) {
          import std.datetime : Clock;

          _notifications[key].sentAt = Clock.currTime();
        }
        return true;
      }
      return false;
    }
  }

  // ──────────────────────────────────────
  //  Data Usage
  // ──────────────────────────────────────

  PDMDataUsage upsertUsage(PDMDataUsage u) {
    synchronized (_mutex) {
      string key = tenantKey(u.tenantId, u.usageId);
      _usages[key] = u;
      return u;
    }
  }

  PDMDataUsage[] listUsagesBySubject(UUID tenantId, UUID subjectId) {
    synchronized (_mutex) {
      return _usages.byValue.filter!(u => u.tenantId == tenantId && u.subjectId == subjectId).array;
    }
  }

  bool removeUsage(UUID tenantId, UUID usageId) {
    synchronized (_mutex) {
      string key = tenantKey(tenantId, usageId);
      if (key in _usages) {
        _usages.remove(key);
        return true;
      }
      return false;
    }
  }
}
