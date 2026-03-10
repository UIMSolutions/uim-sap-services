module uim.sap.pdm.store;

import core.sync.mutex : Mutex;

import vibe.data.json : Json;

import uim.sap.pdm.enumerations;
import uim.sap.pdm.helpers;
import uim.sap.pdm.models;

/**
 * Thread-safe in-memory store for Personal Data Manager.
 *
 * Manages: tenants, data subjects, personal data records,
 * data requests, notifications, and data usage tracking.
 * All keys are tenant-scoped for multitenancy support.
 */
class PDMStore : SAPStore {
    private {
        PDMTenant[string] _tenants;                   // key: tenantId
        PDMDataSubject[string] _subjects;             // key: tenantId/subjectId
        PDMPersonalDataRecord[string] _records;       // key: tenantId/recordId
        PDMDataRequest[string] _requests;             // key: tenantId/requestId
        PDMNotification[string] _notifications;       // key: tenantId/notificationId
        PDMDataUsage[string] _usages;                 // key: tenantId/usageId
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
            _tenants[t.tenantId] = t;
            return t;
        }
    }

    PDMTenant getTenant(string tenantId) {
        synchronized (_mutex) {
            if (auto p = tenantId in _tenants)
                return *p;
            return PDMTenant.init;
        }
    }

    bool hasTenant(string tenantId) {
        synchronized (_mutex) {
            return (tenantId in _tenants) !is null;
        }
    }

    PDMTenant[] listTenants() {
        synchronized (_mutex) {
            return _tenants.values;
        }
    }

    bool removeTenant(string tenantId) {
        synchronized (_mutex) {
            if (tenantId in _tenants) {
                _tenants.remove(tenantId);
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
            auto key = tenantKey(s.tenantId, s.subjectId);
            _subjects[key] = s;
            return s;
        }
    }

    PDMDataSubject getSubject(string tenantId, string subjectId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, subjectId);
            if (auto p = key in _subjects)
                return *p;
            return PDMDataSubject.init;
        }
    }

    bool hasSubject(string tenantId, string subjectId) {
        synchronized (_mutex) {
            return tenantKey(tenantId, subjectId) in _subjects !is null;
        }
    }

    PDMDataSubject[] listSubjects(string tenantId) {
        synchronized (_mutex) {
            PDMDataSubject[] result;
            foreach (ref s; _subjects)
                if (s.tenantId == tenantId) result ~= s;
            return result;
        }
    }

    PDMDataSubject[] searchSubjects(string tenantId, string term) {
        synchronized (_mutex) {
            PDMDataSubject[] result;
            foreach (ref s; _subjects) {
                if (s.tenantId == tenantId && matchesSubject(s, term))
                    result ~= s;
            }
            return result;
        }
    }

    PDMDataSubject[] searchSubjectsByType(string tenantId, PDMSubjectType subjectType) {
        synchronized (_mutex) {
            PDMDataSubject[] result;
            foreach (ref s; _subjects) {
                if (s.tenantId == tenantId && s.subjectType == subjectType)
                    result ~= s;
            }
            return result;
        }
    }

    bool removeSubject(string tenantId, string subjectId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, subjectId);
            if (key in _subjects) {
                _subjects.remove(key);
                return true;
            }
            return false;
        }
    }

    size_t subjectCount(string tenantId) {
        synchronized (_mutex) {
            size_t count = 0;
            foreach (ref s; _subjects)
                if (s.tenantId == tenantId) count++;
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
            auto key = tenantKey(r.tenantId, r.recordId);
            _records[key] = r;
            return r;
        }
    }

    PDMPersonalDataRecord getRecord(string tenantId, string recordId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, recordId);
            if (auto p = key in _records)
                return *p;
            return PDMPersonalDataRecord.init;
        }
    }

    bool hasRecord(string tenantId, string recordId) {
        synchronized (_mutex) {
            return tenantKey(tenantId, recordId) in _records !is null;
        }
    }

    PDMPersonalDataRecord[] listRecordsBySubject(string tenantId, string subjectId) {
        synchronized (_mutex) {
            PDMPersonalDataRecord[] result;
            foreach (ref r; _records)
                if (r.tenantId == tenantId && r.subjectId == subjectId)
                    result ~= r;
            return result;
        }
    }

    bool removeRecord(string tenantId, string recordId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, recordId);
            if (key in _records) {
                _records.remove(key);
                return true;
            }
            return false;
        }
    }

    /// Remove all records for a data subject (erasure)
    size_t removeRecordsBySubject(string tenantId, string subjectId) {
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

    size_t recordCountBySubject(string tenantId, string subjectId) {
        synchronized (_mutex) {
            size_t count = 0;
            foreach (ref r; _records)
                if (r.tenantId == tenantId && r.subjectId == subjectId) count++;
            return count;
        }
    }

    // ──────────────────────────────────────
    //  Data Requests
    // ──────────────────────────────────────

    PDMDataRequest upsertRequest(PDMDataRequest r) {
        synchronized (_mutex) {
            auto key = tenantKey(r.tenantId, r.requestId);
            _requests[key] = r;
            return r;
        }
    }

    PDMDataRequest getRequest(string tenantId, string requestId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, requestId);
            if (auto p = key in _requests)
                return *p;
            return PDMDataRequest.init;
        }
    }

    bool hasRequest(string tenantId, string requestId) {
        synchronized (_mutex) {
            return tenantKey(tenantId, requestId) in _requests !is null;
        }
    }

    PDMDataRequest[] listRequests(string tenantId) {
        synchronized (_mutex) {
            PDMDataRequest[] result;
            foreach (ref r; _requests)
                if (r.tenantId == tenantId) result ~= r;
            return result;
        }
    }

    PDMDataRequest[] listRequestsBySubject(string tenantId, string subjectId) {
        synchronized (_mutex) {
            PDMDataRequest[] result;
            foreach (ref r; _requests)
                if (r.tenantId == tenantId && r.subjectId == subjectId) result ~= r;
            return result;
        }
    }

    PDMDataRequest[] listRequestsByStatus(string tenantId, PDMRequestStatus status) {
        synchronized (_mutex) {
            PDMDataRequest[] result;
            foreach (ref r; _requests)
                if (r.tenantId == tenantId && r.status == status) result ~= r;
            return result;
        }
    }

    size_t requestCount(string tenantId) {
        synchronized (_mutex) {
            size_t count = 0;
            foreach (ref r; _requests)
                if (r.tenantId == tenantId) count++;
            return count;
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
            auto key = tenantKey(n.tenantId, n.notificationId);
            _notifications[key] = n;
            return n;
        }
    }

    PDMNotification getNotification(string tenantId, string notificationId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, notificationId);
            if (auto p = key in _notifications)
                return *p;
            return PDMNotification.init;
        }
    }

    PDMNotification[] listNotificationsBySubject(string tenantId, string subjectId) {
        synchronized (_mutex) {
            PDMNotification[] result;
            foreach (ref n; _notifications)
                if (n.tenantId == tenantId && n.subjectId == subjectId) result ~= n;
            return result;
        }
    }

    bool updateNotificationStatus(string tenantId, string notificationId, PDMNotificationStatus status) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, notificationId);
            if (auto p = key in _notifications) {
                p.status = status;
                if (status == PDMNotificationStatus.sent) {
                    import std.datetime : Clock;
                    p.sentAt = Clock.currTime();
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
            auto key = tenantKey(u.tenantId, u.usageId);
            _usages[key] = u;
            return u;
        }
    }

    PDMDataUsage[] listUsagesBySubject(string tenantId, string subjectId) {
        synchronized (_mutex) {
            PDMDataUsage[] result;
            foreach (ref u; _usages)
                if (u.tenantId == tenantId && u.subjectId == subjectId) result ~= u;
            return result;
        }
    }

    bool removeUsage(string tenantId, string usageId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, usageId);
            if (key in _usages) {
                _usages.remove(key);
                return true;
            }
            return false;
        }
    }
}
