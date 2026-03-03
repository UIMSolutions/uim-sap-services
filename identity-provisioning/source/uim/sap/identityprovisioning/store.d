module uim.sap.identityprovisioning.store;

import core.sync.mutex : Mutex;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

/** Thread-safe in-memory store for all Identity Provisioning data. */
class IPStore : SAPStore {
    private IPSystem[string] _systems;
    private IPUser[string] _users;
    private IPGroup[string] _groups;
    private IPTransformation[string] _transformations;
    private IPJob[string] _jobs;
    private IPJobLog[][string] _jobLogs;        // jobId → logs
    private IPNotification[string] _notifications;

    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    // ─── System operations ────────────────────────────────────

    IPSystem upsertSystem(IPSystem system) {
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

    IPSystem getSystem(string tenantId, string systemName) {
        synchronized (_lock) {
            auto key = systemKey(tenantId, systemName);
            if (auto value = key in _systems)
                return *value;
        }
        return IPSystem.init;
    }

    IPSystem getSystemById(string tenantId, string systemId) {
        synchronized (_lock) {
            foreach (_, sys; _systems) {
                if (sys.tenantId == tenantId && sys.systemId == systemId)
                    return sys;
            }
        }
        return IPSystem.init;
    }

    IPSystem[] listSystems(string tenantId) {
        IPSystem[] list;
        synchronized (_lock) {
            foreach (key, sys; _systems) {
                if (belongsToTenant(key, tenantId))
                    list ~= sys;
            }
        }
        return list;
    }

    IPSystem[] listSystemsByType(string tenantId, string systemType) {
        IPSystem[] list;
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

    IPUser upsertUser(IPUser user) {
        synchronized (_lock) {
            auto key = userKey(user.tenantId, user.userId);
            if (auto existing = key in _users) {
                user.createdAt = existing.createdAt;
            }
            _users[key] = user;
            return user;
        }
    }

    IPUser getUser(string tenantId, string userId) {
        synchronized (_lock) {
            auto key = userKey(tenantId, userId);
            if (auto value = key in _users)
                return *value;
        }
        return IPUser.init;
    }

    IPUser[] listUsers(string tenantId) {
        IPUser[] list;
        synchronized (_lock) {
            foreach (key, user; _users) {
                if (belongsToTenant(key, tenantId))
                    list ~= user;
            }
        }
        return list;
    }

    IPUser[] listUsersBySystem(string tenantId, string systemId) {
        IPUser[] list;
        synchronized (_lock) {
            foreach (key, user; _users) {
                if (belongsToTenant(key, tenantId) && user.sourceSystemId == systemId)
                    list ~= user;
            }
        }
        return list;
    }

    /** List users modified after the given timestamp (for delta reads). */
    IPUser[] listModifiedUsersSince(string tenantId, string systemId, string sinceTimestamp) {
        IPUser[] list;
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

    IPGroup upsertGroup(IPGroup group) {
        synchronized (_lock) {
            auto key = groupKey(group.tenantId, group.groupId);
            if (auto existing = key in _groups) {
                group.createdAt = existing.createdAt;
            }
            _groups[key] = group;
            return group;
        }
    }

    IPGroup getGroup(string tenantId, string groupId) {
        synchronized (_lock) {
            auto key = groupKey(tenantId, groupId);
            if (auto value = key in _groups)
                return *value;
        }
        return IPGroup.init;
    }

    IPGroup[] listGroups(string tenantId) {
        IPGroup[] list;
        synchronized (_lock) {
            foreach (key, group; _groups) {
                if (belongsToTenant(key, tenantId))
                    list ~= group;
            }
        }
        return list;
    }

    IPGroup[] listGroupsBySystem(string tenantId, string systemId) {
        IPGroup[] list;
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

    IPTransformation upsertTransformation(IPTransformation transformation) {
        synchronized (_lock) {
            _transformations[transformation.transformationId] = transformation;
            return transformation;
        }
    }

    IPTransformation getTransformation(string tenantId, string transformationId) {
        synchronized (_lock) {
            if (auto value = transformationId in _transformations) {
                if (value.tenantId == tenantId)
                    return *value;
            }
        }
        return IPTransformation.init;
    }

    IPTransformation[] listTransformations(string tenantId) {
        IPTransformation[] list;
        synchronized (_lock) {
            foreach (_, t; _transformations) {
                if (t.tenantId == tenantId)
                    list ~= t;
            }
        }
        return list;
    }

    IPTransformation[] listTransformationsForSystem(string tenantId, string systemId) {
        IPTransformation[] list;
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

    IPJob upsertJob(IPJob job) {
        synchronized (_lock) {
            _jobs[job.jobId] = job;
            return job;
        }
    }

    IPJob getJob(string tenantId, string jobId) {
        synchronized (_lock) {
            if (auto value = jobId in _jobs) {
                if (value.tenantId == tenantId)
                    return *value;
            }
        }
        return IPJob.init;
    }

    IPJob[] listJobs(string tenantId) {
        IPJob[] list;
        synchronized (_lock) {
            foreach (_, job; _jobs) {
                if (job.tenantId == tenantId)
                    list ~= job;
            }
        }
        return list;
    }

    IPJob[] listJobsBySystem(string tenantId, string sourceSystemId) {
        IPJob[] list;
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

    void appendJobLog(IPJobLog log) {
        synchronized (_lock) {
            _jobLogs[log.jobId] ~= log;
        }
    }

    IPJobLog[] listJobLogs(string tenantId, string jobId) {
        synchronized (_lock) {
            if (auto logs = jobId in _jobLogs) {
                IPJobLog[] filtered;
                foreach (ref log; *logs) {
                    if (log.tenantId == tenantId)
                        filtered ~= log;
                }
                return filtered;
            }
        }
        return [];
    }

    IPJobLog[] listJobLogsByLevel(string tenantId, string jobId, string level) {
        synchronized (_lock) {
            if (auto logs = jobId in _jobLogs) {
                IPJobLog[] filtered;
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

    IPNotification upsertNotification(IPNotification notification) {
        synchronized (_lock) {
            _notifications[notification.subscriptionId] = notification;
            return notification;
        }
    }

    IPNotification getNotification(string tenantId, string subscriptionId) {
        synchronized (_lock) {
            if (auto value = subscriptionId in _notifications) {
                if (value.tenantId == tenantId)
                    return *value;
            }
        }
        return IPNotification.init;
    }

    IPNotification[] listNotifications(string tenantId) {
        IPNotification[] list;
        synchronized (_lock) {
            foreach (_, n; _notifications) {
                if (n.tenantId == tenantId)
                    list ~= n;
            }
        }
        return list;
    }

    IPNotification[] listNotificationsForSystem(string tenantId, string sourceSystemId) {
        IPNotification[] list;
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
