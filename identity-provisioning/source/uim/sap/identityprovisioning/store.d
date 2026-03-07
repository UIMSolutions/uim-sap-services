/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.identityprovisioning.store;

import core.sync.mutex : Mutex;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

/** Thread-safe in-memory store for all Identity Provisioning data. */
class IPVStore : SAPStore {
    private IPVSystem[string] _systems;
    private IPVUser[string] _users;
    private IPVGroup[string] _groups;
    private IPVTransformation[string] _transformations;
    private IPVJob[string] _jobs;
    private IPVJobLog[][string] _jobLogs;        // jobId → logs
    private IPVNotification[string] _notifications;

    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    // ─── System operations ────────────────────────────────────

    IPVSystem upsertSystem(IPVSystem system) {
        synchronized (_lock) {
            auto key = systemKey(system.tenantId, system.systemName);
            if (auto existing = key in _systems) {
                system.createdAt = existing.createdAt;
                system.userCount = existing.userCount;
                system.groupCount = existing.groupCount;
            }
            _systems[key] = system;
            return system;
        }
    }

    IPVSystem getSystem(string tenantId, string systemName) {
        synchronized (_lock) {
            auto key = systemKey(tenantId, systemName);
            if (auto value = key in _systems)
                return *value;
        }
        return IPVSystem.init;
    }

    IPVSystem getSystemById(string tenantId, string systemId) {
        synchronized (_lock) {
            foreach (_, sys; _systems) {
                if (sys.tenantId == tenantId && sys.systemId == systemId)
                    return sys;
            }
        }
        return IPVSystem.init;
    }

    IPVSystem[] listSystems(string tenantId) {
        IPVSystem[] list;
        synchronized (_lock) {
            foreach (key, sys; _systems) {
                if (belongsToTenant(key, tenantId))
                    list ~= sys;
            }
        }
        return list;
    }

    IPVSystem[] listSystemsByType(string tenantId, string systemType) {
        IPVSystem[] list;
        synchronized (_lock) {
            foreach (key, sys; _systems) {
                if (belongsToTenant(key, tenantId) && sys.systemType == systemType)
                    list ~= sys;
            }
        }
        return list;
    }

    bool deleteSystem(string tenantId, string systemName) {
        synchronized (_lock) {
            auto key = systemKey(tenantId, systemName);
            if (key in _systems) {
                _systems.remove(key);
                return true;
            }
        }
        return false;
    }

    // ─── User operations ──────────────────────────────────────

    IPVUser upsertUser(IPVUser user) {
        synchronized (_lock) {
            auto key = userKey(user.tenantId, user.userId);
            if (auto existing = key in _users) {
                user.createdAt = existing.createdAt;
            }
            _users[key] = user;
            return user;
        }
    }

    IPVUser getUser(string tenantId, string userId) {
        synchronized (_lock) {
            auto key = userKey(tenantId, userId);
            if (auto value = key in _users)
                return *value;
        }
        return IPVUser.init;
    }

    IPVUser[] listUsers(string tenantId) {
        IPVUser[] list;
        synchronized (_lock) {
            foreach (key, user; _users) {
                if (belongsToTenant(key, tenantId))
                    list ~= user;
            }
        }
        return list;
    }

    IPVUser[] listUsersBySystem(string tenantId, string systemId) {
        IPVUser[] list;
        synchronized (_lock) {
            foreach (key, user; _users) {
                if (belongsToTenant(key, tenantId) && user.sourceSystemId == systemId)
                    list ~= user;
            }
        }
        return list;
    }

    /** List users modified after the given timestamp (for delta reads). */
    IPVUser[] listModifiedUsersSince(string tenantId, string systemId, string sinceTimestamp) {
        IPVUser[] list;
        synchronized (_lock) {
            foreach (key, user; _users) {
                if (belongsToTenant(key, tenantId)
                    && user.sourceSystemId == systemId
                    && user.lastModifiedAt > sinceTimestamp) {
                    list ~= user;
                }
            }
        }
        return list;
    }

    bool deleteUser(string tenantId, string userId) {
        synchronized (_lock) {
            auto key = userKey(tenantId, userId);
            if (key in _users) {
                _users.remove(key);
                return true;
            }
        }
        return false;
    }

    // ─── Group operations ─────────────────────────────────────

    IPVGroup upsertGroup(IPVGroup group) {
        synchronized (_lock) {
            auto key = groupKey(group.tenantId, group.groupId);
            if (auto existing = key in _groups) {
                group.createdAt = existing.createdAt;
            }
            _groups[key] = group;
            return group;
        }
    }

    IPVGroup getGroup(string tenantId, string groupId) {
        synchronized (_lock) {
            auto key = groupKey(tenantId, groupId);
            if (auto value = key in _groups)
                return *value;
        }
        return IPVGroup.init;
    }

    IPVGroup[] listGroups(string tenantId) {
        IPVGroup[] list;
        synchronized (_lock) {
            foreach (key, group; _groups) {
                if (belongsToTenant(key, tenantId))
                    list ~= group;
            }
        }
        return list;
    }

    IPVGroup[] listGroupsBySystem(string tenantId, string systemId) {
        IPVGroup[] list;
        synchronized (_lock) {
            foreach (key, group; _groups) {
                if (belongsToTenant(key, tenantId) && group.sourceSystemId == systemId)
                    list ~= group;
            }
        }
        return list;
    }

    bool deleteGroup(string tenantId, string groupId) {
        synchronized (_lock) {
            auto key = groupKey(tenantId, groupId);
            if (key in _groups) {
                _groups.remove(key);
                return true;
            }
        }
        return false;
    }

    // ─── Transformation operations ────────────────────────────

    IPVTransformation upsertTransformation(IPVTransformation transformation) {
        synchronized (_lock) {
            _transformations[transformation.transformationId] = transformation;
            return transformation;
        }
    }

    IPVTransformation getTransformation(string tenantId, string transformationId) {
        synchronized (_lock) {
            if (auto value = transformationId in _transformations) {
                if (value.tenantId == tenantId)
                    return *value;
            }
        }
        return IPVTransformation.init;
    }

    IPVTransformation[] listTransformations(string tenantId) {
        IPVTransformation[] list;
        synchronized (_lock) {
            foreach (_, t; _transformations) {
                if (t.tenantId == tenantId)
                    list ~= t;
            }
        }
        return list;
    }

    IPVTransformation[] listTransformationsForSystem(string tenantId, string systemId) {
        IPVTransformation[] list;
        synchronized (_lock) {
            foreach (_, t; _transformations) {
                if (t.tenantId == tenantId && t.systemId == systemId && t.active)
                    list ~= t;
            }
        }
        return list;
    }

    bool deleteTransformation(string tenantId, string transformationId) {
        synchronized (_lock) {
            if (auto t = transformationId in _transformations) {
                if (t.tenantId == tenantId) {
                    _transformations.remove(transformationId);
                    return true;
                }
            }
        }
        return false;
    }

    // ─── Job operations ───────────────────────────────────────

    IPVJob upsertJob(IPVJob job) {
        synchronized (_lock) {
            _jobs[job.jobId] = job;
            return job;
        }
    }

    IPVJob getJob(string tenantId, string jobId) {
        synchronized (_lock) {
            if (auto value = jobId in _jobs) {
                if (value.tenantId == tenantId)
                    return *value;
            }
        }
        return IPVJob.init;
    }

    IPVJob[] listJobs(string tenantId) {
        IPVJob[] list;
        synchronized (_lock) {
            foreach (_, job; _jobs) {
                if (job.tenantId == tenantId)
                    list ~= job;
            }
        }
        return list;
    }

    IPVJob[] listJobsBySystem(string tenantId, string sourceSystemId) {
        IPVJob[] list;
        synchronized (_lock) {
            foreach (_, job; _jobs) {
                if (job.tenantId == tenantId && job.sourceSystemId == sourceSystemId)
                    list ~= job;
            }
        }
        return list;
    }

    bool deleteJob(string tenantId, string jobId) {
        synchronized (_lock) {
            if (auto j = jobId in _jobs) {
                if (j.tenantId == tenantId) {
                    _jobs.remove(jobId);
                    _jobLogs.remove(jobId);
                    return true;
                }
            }
        }
        return false;
    }

    // ─── Job log operations ───────────────────────────────────

    void appendJobLog(IPVJobLog log) {
        synchronized (_lock) {
            _jobLogs[log.jobId] ~= log;
        }
    }

    IPVJobLog[] listJobLogs(string tenantId, string jobId) {
        synchronized (_lock) {
            if (auto logs = jobId in _jobLogs) {
                IPVJobLog[] filtered;
                foreach (ref log; *logs) {
                    if (log.tenantId == tenantId)
                        filtered ~= log;
                }
                return filtered;
            }
        }
        return [];
    }

    IPVJobLog[] listJobLogsByLevel(string tenantId, string jobId, string level) {
        synchronized (_lock) {
            if (auto logs = jobId in _jobLogs) {
                IPVJobLog[] filtered;
                foreach (ref log; *logs) {
                    if (log.tenantId == tenantId && log.level == level)
                        filtered ~= log;
                }
                return filtered;
            }
        }
        return [];
    }

    // ─── Notification subscription operations ─────────────────

    IPVNotification upsertNotification(IPVNotification notification) {
        synchronized (_lock) {
            _notifications[notification.subscriptionId] = notification;
            return notification;
        }
    }

    IPVNotification getNotification(string tenantId, string subscriptionId) {
        synchronized (_lock) {
            if (auto value = subscriptionId in _notifications) {
                if (value.tenantId == tenantId)
                    return *value;
            }
        }
        return IPVNotification.init;
    }

    IPVNotification[] listNotifications(string tenantId) {
        IPVNotification[] list;
        synchronized (_lock) {
            foreach (_, n; _notifications) {
                if (n.tenantId == tenantId)
                    list ~= n;
            }
        }
        return list;
    }

    IPVNotification[] listNotificationsForSystem(string tenantId, string sourceSystemId) {
        IPVNotification[] list;
        synchronized (_lock) {
            foreach (_, n; _notifications) {
                if (n.tenantId == tenantId && n.sourceSystemId == sourceSystemId && n.active)
                    list ~= n;
            }
        }
        return list;
    }

    bool deleteNotification(string tenantId, string subscriptionId) {
        synchronized (_lock) {
            if (auto n = subscriptionId in _notifications) {
                if (n.tenantId == tenantId) {
                    _notifications.remove(subscriptionId);
                    return true;
                }
            }
        }
        return false;
    }

    /** Update system entity counts. */
    void updateSystemCounts(string tenantId, string systemId, long userCount, long groupCount) {
        synchronized (_lock) {
            foreach (key, ref sys; _systems) {
                if (sys.tenantId == tenantId && sys.systemId == systemId) {
                    sys.userCount = userCount;
                    sys.groupCount = groupCount;
                    sys.lastSyncAt = Clock.currTime().toISOExtString();
                    sys.updatedAt = sys.lastSyncAt;
                    break;
                }
            }
        }
    }

    // ─── Key helpers ──────────────────────────────────────────

    private string systemKey(string tenantId, string systemName) {
        return tenantId ~ ":system:" ~ systemName;
    }

    private string userKey(string tenantId, string userId) {
        return tenantId ~ ":user:" ~ userId;
    }

    private string groupKey(string tenantId, string groupId) {
        return tenantId ~ ":group:" ~ groupId;
    }

    private bool belongsToTenant(string key, string tenantId) {
        return key.length > tenantId.length + 1
            && key[0 .. tenantId.length] == tenantId
            && key[tenantId.length] == ':';
    }
}
