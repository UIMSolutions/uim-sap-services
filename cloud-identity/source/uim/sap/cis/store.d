module uim.sap.cis.store;

import core.sync.mutex : Mutex;

import uim.sap.cis;

mixin(ShowModule!());

@safe:


class CISStore {
    private CISUser[string] _users;
    private CISGroup[string] _groups;
    private CISDelegationRule[string] _delegationRules;
    private CISAuthorizationPolicy[string] _policies;
    private CISRiskPolicy[string] _riskPolicies;
    private CISProvisioningJob[string] _jobs;
    private CISJobLog[] _jobLogs;
    private CISNotificationSubscription[string] _subscriptions;
    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    CISUser upsertUser(CISUser user) {
        synchronized (_lock) {
            auto key = scopedKey(user.tenantId, "user", user.userId);
            if (auto existing = key in _users) {
                user.createdAt = existing.createdAt;
            }
            _users[key] = user;
            return user;
        }
    }

    CISUser getUser(string tenantId, string userId) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "user", userId);
            if (auto value = key in _users) return *value;
        }
        return CISUser.init;
    }

    CISUser[] listUsers(string tenantId) {
        CISUser[] values;
        synchronized (_lock) {
            foreach (key, value; _users) {
                if (belongsTo(key, tenantId)) values ~= value;
            }
        }
        return values;
    }

    CISGroup upsertGroup(CISGroup group) {
        synchronized (_lock) {
            auto key = scopedKey(group.tenantId, "group", group.groupId);
            _groups[key] = group;
            return group;
        }
    }

    CISGroup[] listGroups(string tenantId) {
        CISGroup[] values;
        synchronized (_lock) {
            foreach (key, value; _groups) {
                if (belongsTo(key, tenantId)) values ~= value;
            }
        }
        return values;
    }

    CISDelegationRule upsertDelegationRule(CISDelegationRule rule) {
        synchronized (_lock) {
            _delegationRules[scopedKey(rule.tenantId, "delegation", rule.ruleId)] = rule;
            return rule;
        }
    }

    CISDelegationRule[] listDelegationRules(string tenantId) {
        CISDelegationRule[] values;
        synchronized (_lock) {
            foreach (key, value; _delegationRules) {
                if (belongsTo(key, tenantId)) values ~= value;
            }
        }
        return values;
    }

    CISAuthorizationPolicy upsertPolicy(CISAuthorizationPolicy policy) {
        synchronized (_lock) {
            _policies[scopedKey(policy.tenantId, "policy", policy.policyId)] = policy;
            return policy;
        }
    }

    CISAuthorizationPolicy[] listPolicies(string tenantId) {
        CISAuthorizationPolicy[] values;
        synchronized (_lock) {
            foreach (key, value; _policies) {
                if (belongsTo(key, tenantId)) values ~= value;
            }
        }
        return values;
    }

    CISRiskPolicy upsertRiskPolicy(CISRiskPolicy policy) {
        synchronized (_lock) {
            _riskPolicies[scopedKey(policy.tenantId, "risk", policy.policyId)] = policy;
            return policy;
        }
    }

    CISRiskPolicy[] listRiskPolicies(string tenantId) {
        CISRiskPolicy[] values;
        synchronized (_lock) {
            foreach (key, value; _riskPolicies) {
                if (belongsTo(key, tenantId)) values ~= value;
            }
        }
        return values;
    }

    CISProvisioningJob upsertJob(CISProvisioningJob job) {
        synchronized (_lock) {
            _jobs[scopedKey(job.tenantId, "job", job.jobId)] = job;
            return job;
        }
    }

    CISProvisioningJob[] listJobs(string tenantId) {
        CISProvisioningJob[] values;
        synchronized (_lock) {
            foreach (key, value; _jobs) {
                if (belongsTo(key, tenantId)) values ~= value;
            }
        }
        return values;
    }

    CISJobLog appendJobLog(CISJobLog log) {
        synchronized (_lock) {
            _jobLogs ~= log;
            return log;
        }
    }

    CISJobLog[] listJobLogs(string tenantId) {
        CISJobLog[] values;
        synchronized (_lock) {
            foreach (log; _jobLogs) {
                if (log.tenantId == tenantId) values ~= log;
            }
        }
        return values;
    }

    CISNotificationSubscription upsertSubscription(CISNotificationSubscription subscription) {
        synchronized (_lock) {
            _subscriptions[scopedKey(subscription.tenantId, "subscription", subscription.subscriptionId)] = subscription;
            return subscription;
        }
    }

    CISNotificationSubscription[] listSubscriptions(string tenantId) {
        CISNotificationSubscription[] values;
        synchronized (_lock) {
            foreach (key, value; _subscriptions) {
                if (belongsTo(key, tenantId)) values ~= value;
            }
        }
        return values;
    }

    private string scopedKey(string tenantId, string scopePart, string id) {
        return tenantId ~ ":" ~ scopePart ~ ":" ~ id;
    }

    private bool belongsTo(string key, string tenantId) {
        return key.length > tenantId.length + 1 && key[0 .. tenantId.length] == tenantId && key[tenantId.length] == ':';
    }
}
