module uim.sap.auditlog.store;

import core.sync.mutex : Mutex;
import std.datetime : Clock, dur;

import uim.sap.auditlog.models;

class AuditLogStore {
    private AuditLogEvent[][string] _eventsByTenant;
    private AuditLogRetentionPolicy[string] _policies;
    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    AuditLogEvent appendEvent(AuditLogEvent eventItem) {
        synchronized (_lock) {
            _eventsByTenant[eventItem.tenantId] ~= eventItem;
            return eventItem;
        }
    }

    AuditLogEvent[] listEvents(string tenantId) {
        synchronized (_lock) {
            if (auto events = tenantId in _eventsByTenant) {
                return (*events).dup;
            }
        }
        return [];
    }

    void purgeExpired(string tenantId, int retentionDays) {
        synchronized (_lock) {
            if (auto events = tenantId in _eventsByTenant) {
                AuditLogEvent[] filtered;
                auto threshold = Clock.currTime() - dur!"days"(retentionDays);
                foreach (eventItem; *events) {
                    if (eventItem.createdAt >= threshold) {
                        filtered ~= eventItem;
                    }
                }
                _eventsByTenant[tenantId] = filtered;
            }
        }
    }

    AuditLogRetentionPolicy upsertPolicy(AuditLogRetentionPolicy policy) {
        synchronized (_lock) {
            _policies[policy.tenantId] = policy;
            return policy;
        }
    }

    AuditLogRetentionPolicy getPolicy(string tenantId) {
        synchronized (_lock) {
            if (auto policy = tenantId in _policies) {
                return *policy;
            }
        }
        return AuditLogRetentionPolicy.init;
    }
}
