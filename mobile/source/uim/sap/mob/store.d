module uim.sap.mob.store;

import core.sync.mutex : Mutex;

import vibe.data.json : Json;

import uim.sap.mob.enumerations;
import uim.sap.mob.helpers;
import uim.sap.mob.models;

/**
 * Thread-safe in-memory store for Mobile Services data.
 *
 * Manages: applications, versions, push configs, notifications,
 * offline configs, security policies, and user connections.
 */
class MOBStore : SAPStore {
    private {
        MOBApplication[string] _apps;
        MOBAppVersion[string] _versions;        // key: appId/versionId
        MOBPushConfig[string] _pushConfigs;     // key: appId
        MOBNotification[][string] _notifications; // key: appId → list
        MOBOfflineConfig[string] _offlineConfigs; // key: appId
        MOBSecurityPolicy[string] _securityPolicies; // key: appId
        MOBUserConnection[string] _users;       // key: appId/userId
        Mutex _mutex;
    }

    this() {
        _mutex = new Mutex;
    }

    // ──────────────────────────────────────
    //  Applications
    // ──────────────────────────────────────

    MOBApplication upsertApp(MOBApplication app) {
        synchronized (_mutex) {
            _apps[app.appId] = app;
            return app;
        }
    }

    MOBApplication getApp(string appId) {
        synchronized (_mutex) {
            if (auto p = appId in _apps)
                return *p;
            return MOBApplication.init;
        }
    }

    bool hasApp(string appId) {
        synchronized (_mutex) {
            return (appId in _apps) !is null;
        }
    }

    MOBApplication[] listApps() {
        synchronized (_mutex) {
            return _apps.values;
        }
    }

    size_t appCount() {
        synchronized (_mutex) {
            return _apps.length;
        }
    }

    bool deleteApp(string appId) {
        synchronized (_mutex) {
            if (appId !in _apps)
                return false;
            _apps.remove(appId);
            // Cascade: remove all related resources
            _pushConfigs.remove(appId);
            _offlineConfigs.remove(appId);
            _securityPolicies.remove(appId);
            _notifications.remove(appId);
            removeByPrefix(_versions, appId ~ "/");
            removeByPrefix(_users, appId ~ "/");
            return true;
        }
    }

    // ──────────────────────────────────────
    //  App Versions
    // ──────────────────────────────────────

    MOBAppVersion upsertVersion(MOBAppVersion ver) {
        synchronized (_mutex) {
            _versions[appKey(ver.appId, ver.versionId)] = ver;
            return ver;
        }
    }

    MOBAppVersion getVersion(string appId, string versionId) {
        synchronized (_mutex) {
            if (auto p = appKey(appId, versionId) in _versions)
                return *p;
            return MOBAppVersion.init;
        }
    }

    MOBAppVersion[] listVersions(string appId) {
        synchronized (_mutex) {
            MOBAppVersion[] result;
            auto prefix = appId ~ "/";
            foreach (k, v; _versions)
                if (k.length > prefix.length && k[0 .. prefix.length] == prefix)
                    result ~= v;
            return result;
        }
    }

    size_t versionCount(string appId) {
        synchronized (_mutex) {
            size_t count;
            auto prefix = appId ~ "/";
            foreach (k; _versions.byKey())
                if (k.length > prefix.length && k[0 .. prefix.length] == prefix)
                    count++;
            return count;
        }
    }

    bool deleteVersion(string appId, string versionId) {
        synchronized (_mutex) {
            auto key = appKey(appId, versionId);
            if (key !in _versions)
                return false;
            _versions.remove(key);
            return true;
        }
    }

    // ──────────────────────────────────────
    //  Push Configuration
    // ──────────────────────────────────────

    MOBPushConfig upsertPushConfig(MOBPushConfig pc) {
        synchronized (_mutex) {
            _pushConfigs[pc.appId] = pc;
            return pc;
        }
    }

    MOBPushConfig getPushConfig(string appId) {
        synchronized (_mutex) {
            if (auto p = appId in _pushConfigs)
                return *p;
            return MOBPushConfig.init;
        }
    }

    bool hasPushConfig(string appId) {
        synchronized (_mutex) {
            return (appId in _pushConfigs) !is null;
        }
    }

    // ──────────────────────────────────────
    //  Push Notifications
    // ──────────────────────────────────────

    void recordNotification(MOBNotification n) {
        synchronized (_mutex) {
            if (n.appId !in _notifications)
                _notifications[n.appId] = [];
            _notifications[n.appId] ~= n;
        }
    }

    MOBNotification[] listNotifications(string appId) {
        synchronized (_mutex) {
            if (auto p = appId in _notifications)
                return *p;
            return [];
        }
    }

    size_t notificationCount(string appId) {
        synchronized (_mutex) {
            if (auto p = appId in _notifications)
                return (*p).length;
            return 0;
        }
    }

    // ──────────────────────────────────────
    //  Offline Configuration
    // ──────────────────────────────────────

    MOBOfflineConfig upsertOfflineConfig(MOBOfflineConfig oc) {
        synchronized (_mutex) {
            _offlineConfigs[oc.appId] = oc;
            return oc;
        }
    }

    MOBOfflineConfig getOfflineConfig(string appId) {
        synchronized (_mutex) {
            if (auto p = appId in _offlineConfigs)
                return *p;
            return MOBOfflineConfig.init;
        }
    }

    bool hasOfflineConfig(string appId) {
        synchronized (_mutex) {
            return (appId in _offlineConfigs) !is null;
        }
    }

    // ──────────────────────────────────────
    //  Security Policies
    // ──────────────────────────────────────

    MOBSecurityPolicy upsertSecurityPolicy(MOBSecurityPolicy sp) {
        synchronized (_mutex) {
            _securityPolicies[sp.appId] = sp;
            return sp;
        }
    }

    MOBSecurityPolicy getSecurityPolicy(string appId) {
        synchronized (_mutex) {
            if (auto p = appId in _securityPolicies)
                return *p;
            return MOBSecurityPolicy.init;
        }
    }

    bool hasSecurityPolicy(string appId) {
        synchronized (_mutex) {
            return (appId in _securityPolicies) !is null;
        }
    }

    // ──────────────────────────────────────
    //  User Connections
    // ──────────────────────────────────────

    MOBUserConnection upsertUser(MOBUserConnection uc) {
        synchronized (_mutex) {
            _users[appKey(uc.appId, uc.userId)] = uc;
            return uc;
        }
    }

    MOBUserConnection getUser(string appId, string userId) {
        synchronized (_mutex) {
            if (auto p = appKey(appId, userId) in _users)
                return *p;
            return MOBUserConnection.init;
        }
    }

    MOBUserConnection[] listUsers(string appId) {
        synchronized (_mutex) {
            MOBUserConnection[] result;
            auto prefix = appId ~ "/";
            foreach (k, v; _users)
                if (k.length > prefix.length && k[0 .. prefix.length] == prefix)
                    result ~= v;
            return result;
        }
    }

    size_t userCount(string appId) {
        synchronized (_mutex) {
            size_t count;
            auto prefix = appId ~ "/";
            foreach (k; _users.byKey())
                if (k.length > prefix.length && k[0 .. prefix.length] == prefix)
                    count++;
            return count;
        }
    }

    bool deleteUser(string appId, string userId) {
        synchronized (_mutex) {
            auto key = appKey(appId, userId);
            if (key !in _users)
                return false;
            _users.remove(key);
            return true;
        }
    }

    // ──────────────────────────────────────
    //  Metrics / Analytics
    // ──────────────────────────────────────

    MOBUsageReport appUsageReport(string appId) {
        synchronized (_mutex) {
            MOBUsageReport r;
            r.appId = appId;

            auto prefix = appId ~ "/";
            foreach (k, v; _users) {
                if (k.length > prefix.length && k[0 .. prefix.length] == prefix) {
                    r.totalUsers++;
                    r.totalSessions += v.sessionCount;
                    final switch (v.status) {
                        case MOBConnectionStatus.ACTIVE: r.activeUsers++; break;
                        case MOBConnectionStatus.LOCKED: r.lockedUsers++; break;
                        case MOBConnectionStatus.WIPED: r.wipedUsers++; break;
                        case MOBConnectionStatus.DELETED: break;
                    }
                }
            }

            foreach (k, v; _versions) {
                if (k.length > prefix.length && k[0 .. prefix.length] == prefix)
                    r.totalVersions++;
            }

            if (auto p = appId in _notifications) {
                r.totalPushSent = (*p).length;
                foreach (ref n; *p) {
                    r.totalPushDelivered += n.deliveredCount;
                    r.totalPushFailed += n.failedCount;
                }
            }

            if (auto app = appId in _apps)
                r.activeVersion = (*app).activeVersion;

            return r;
        }
    }

    MOBGlobalMetrics globalMetrics() {
        synchronized (_mutex) {
            MOBGlobalMetrics m;
            m.totalApplications = _apps.length;
            foreach (ref app; _apps) {
                if (app.status == MOBAppStatus.ACTIVE)
                    m.activeApplications++;
            }
            m.totalUsers = _users.length;
            foreach (ref list; _notifications)
                m.totalPushSent += list.length;
            m.totalVersions = _versions.length;
            return m;
        }
    }

    // ── Helper ──

    private void removeByPrefix(V)(ref V[string] map, string prefix) {
        string[] toRemove;
        foreach (k; map.byKey())
            if (k.length >= prefix.length && k[0 .. prefix.length] == prefix)
                toRemove ~= k;
        foreach (k; toRemove)
            map.remove(k);
    }
}
