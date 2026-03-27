/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.featureflags.store;

import core.sync.mutex : Mutex;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

/** Thread-safe in-memory store for feature flag data.
 *
 *  All public methods acquire the mutex before touching
 *  associative arrays, making the store safe for concurrent
 *  vibe.d request handling.
 */
class FFLStore : SAPStore {
    private FFLFlag[string] _flags;      // key = tenantId:flag:flagName
    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    // --- Flag CRUD ---

    FFLFlag upsertFlag(FFLFlag flag) {
        synchronized (_lock) {
            auto key = flagKey(flag.tenantId, flag.flagName);
            if (auto existing = key in _flags) {
                flag.createdAt = existing.createdAt;
                // preserve cumulative evaluation count on update
                if (flag.evaluationCount == 0) {
                    flag.evaluationCount = existing.evaluationCount;
                }
            }
            _flags[key] = flag;
            return flag;
        }
    }

    FFLFlag getFlag(UUID tenantId, string flagName) {
        synchronized (_lock) {
            auto key = flagKey(tenantId, flagName);
            if (auto value = key in _flags) {
                return *value;
            }
        }
        return FFLFlag.init;
    }

    FFLFlag getFlagById(UUID tenantId, string flagId) {
        synchronized (_lock) {
            foreach (_, flag; _flags) {
                if (flag.tenantId == tenantId && flag.flagId == flagId) {
                    return flag;
                }
            }
        }
        return FFLFlag.init;
    }

    FFLFlag[] listFlags(UUID tenantId) {
        FFLFlag[] list;
        synchronized (_lock) {
            foreach (key, flag; _flags) {
                if (belongsToTenant(key, tenantId)) {
                    list ~= flag;
                }
            }
        }
        return list;
    }

    bool deleteFlag(UUID tenantId, string flagName) {
        synchronized (_lock) {
            auto key = flagKey(tenantId, flagName);
            if (key in _flags) {
                _flags.remove(key);
                return true;
            }
        }
        return false;
    }

    /** Atomically increment the evaluation count and persist. */
    void incrementEvaluationCount(UUID tenantId, string flagName) {
        synchronized (_lock) {
            auto key = flagKey(tenantId, flagName);
            if (auto flag = key in _flags) {
                flag.evaluationCount = flag.evaluationCount + 1;
                flag.updatedAt = Clock.currTime();
            }
        }
    }

    /** Replace all flags for a tenant (used by import). */
    long importFlags(UUID tenantId, FFLFlag[] flags) {
        synchronized (_lock) {
            // Remove existing flags for the tenant
            string[] keysToRemove;
            foreach (key, _; _flags) {
                if (belongsToTenant(key, tenantId)) {
                    keysToRemove ~= key;
                }
            }
            foreach (key; keysToRemove) {
                _flags.remove(key);
            }

            // Insert new flags
            foreach (flag; flags) {
                auto key = flagKey(flag.tenantId, flag.flagName);
                _flags[key] = flag;
            }
            return cast(long) flags.length;
        }
    }

    // --- Key helpers ---

    private string flagKey(UUID tenantId, string flagName) {
        return tenantId ~ ":flag:" ~ flagName;
    }

    private bool belongsToTenant(string key, UUID tenantId) {
        return key.length > tenantId.length + 1
            && key[0 .. tenantId.length] == tenantId
            && key[tenantId.length] == ':';
    }
}
