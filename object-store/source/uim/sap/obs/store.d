module uim.sap.obs.store;

import core.sync.mutex : Mutex;

import vibe.data.json : Json;

import uim.sap.obs.enumerations;
import uim.sap.obs.helpers;
import uim.sap.obs.models;

/**
 * Thread-safe in-memory store for Object Store data.
 *
 * Manages: buckets, stored objects, credentials, policies, versions.
 */
class OBSStore : SAPStore {
    private {
        OBSBucket[string] _buckets;                  // key: bucketId
        OBSStoredObject[string] _objects;             // key: bucketId/key
        OBSCredential[string] _credentials;           // key: credentialId
        OBSBucketPolicy[string] _policies;            // key: policyId
        OBSObjectVersion[][string] _versions;         // key: bucketId/key → version list
        Mutex _mutex;
    }

    this() {
        _mutex = new Mutex;
    }

    // ──────────────────────────────────────
    //  Buckets
    // ──────────────────────────────────────

    OBSBucket upsertBucket(OBSBucket b) {
        synchronized (_mutex) {
            _buckets[b.bucketId] = b;
            return b;
        }
    }

    OBSBucket getBucket(string bucketId) {
        synchronized (_mutex) {
            if (auto p = bucketId in _buckets)
                return *p;
            return OBSBucket.init;
        }
    }

    bool hasBucket(string bucketId) {
        synchronized (_mutex) {
            return (bucketId in _buckets) !is null;
        }
    }

    OBSBucket[] listBuckets() {
        synchronized (_mutex) {
            return _buckets.values;
        }
    }

    bool removeBucket(string bucketId) {
        synchronized (_mutex) {
            if (bucketId in _buckets) {
                _buckets.remove(bucketId);
                return true;
            }
            return false;
        }
    }

    size_t bucketCount() {
        synchronized (_mutex) {
            return _buckets.length;
        }
    }

    bool hasBucketByName(string name) {
        synchronized (_mutex) {
            foreach (ref b; _buckets) {
                if (b.name == name) return true;
            }
            return false;
        }
    }

    // ──────────────────────────────────────
    //  Objects
    // ──────────────────────────────────────

    private static string objectKey(string bucketId, string key) {
        return bucketId ~ "/" ~ key;
    }

    OBSStoredObject upsertObject(OBSStoredObject o) {
        synchronized (_mutex) {
            auto k = objectKey(o.bucketId, o.key);
            _objects[k] = o;
            return o;
        }
    }

    OBSStoredObject getObject(string bucketId, string key) {
        synchronized (_mutex) {
            auto k = objectKey(bucketId, key);
            if (auto p = k in _objects)
                return *p;
            return OBSStoredObject.init;
        }
    }

    bool hasObject(string bucketId, string key) {
        synchronized (_mutex) {
            return (objectKey(bucketId, key) in _objects) !is null;
        }
    }

    OBSStoredObject[] listObjects(string bucketId) {
        synchronized (_mutex) {
            OBSStoredObject[] result;
            foreach (ref o; _objects) {
                if (o.bucketId == bucketId && o.status == OBSObjectStatus.active)
                    result ~= o;
            }
            return result;
        }
    }

    OBSStoredObject[] listObjectsByPrefix(string bucketId, string prefix) {
        synchronized (_mutex) {
            import std.string : startsWith;
            OBSStoredObject[] result;
            foreach (ref o; _objects) {
                if (o.bucketId == bucketId && o.status == OBSObjectStatus.active
                        && o.key.startsWith(prefix))
                    result ~= o;
            }
            return result;
        }
    }

    bool removeObject(string bucketId, string key) {
        synchronized (_mutex) {
            auto k = objectKey(bucketId, key);
            if (k in _objects) {
                _objects.remove(k);
                return true;
            }
            return false;
        }
    }

    size_t objectCountForBucket(string bucketId) {
        synchronized (_mutex) {
            size_t count = 0;
            foreach (ref o; _objects) {
                if (o.bucketId == bucketId && o.status == OBSObjectStatus.active)
                    count++;
            }
            return count;
        }
    }

    size_t totalSizeForBucket(string bucketId) {
        synchronized (_mutex) {
            size_t total = 0;
            foreach (ref o; _objects) {
                if (o.bucketId == bucketId && o.status == OBSObjectStatus.active)
                    total += o.sizeBytes;
            }
            return total;
        }
    }

    /// Remove all objects belonging to a bucket
    size_t removeObjectsByBucket(string bucketId) {
        synchronized (_mutex) {
            string[] toRemove;
            foreach (k, ref o; _objects) {
                if (o.bucketId == bucketId)
                    toRemove ~= k;
            }
            foreach (k; toRemove)
                _objects.remove(k);
            return toRemove.length;
        }
    }

    // ──────────────────────────────────────
    //  Credentials
    // ──────────────────────────────────────

    OBSCredential storeCredential(OBSCredential c) {
        synchronized (_mutex) {
            _credentials[c.credentialId] = c;
            return c;
        }
    }

    OBSCredential getCredential(string credentialId) {
        synchronized (_mutex) {
            if (auto p = credentialId in _credentials)
                return *p;
            return OBSCredential.init;
        }
    }

    bool hasCredential(string credentialId) {
        synchronized (_mutex) {
            return (credentialId in _credentials) !is null;
        }
    }

    OBSCredential[] listCredentials(string bucketId) {
        synchronized (_mutex) {
            OBSCredential[] result;
            foreach (ref c; _credentials) {
                if (c.bucketId == bucketId && c.status == OBSCredentialStatus.active)
                    result ~= c;
            }
            return result;
        }
    }

    bool revokeCredential(string credentialId) {
        synchronized (_mutex) {
            if (auto p = credentialId in _credentials) {
                p.status = OBSCredentialStatus.revoked;
                return true;
            }
            return false;
        }
    }

    /// Revoke all credentials for a bucket
    size_t revokeCredentialsByBucket(string bucketId) {
        synchronized (_mutex) {
            size_t count = 0;
            foreach (ref c; _credentials) {
                if (c.bucketId == bucketId && c.status == OBSCredentialStatus.active) {
                    c.status = OBSCredentialStatus.revoked;
                    count++;
                }
            }
            return count;
        }
    }

    size_t credentialCount() {
        synchronized (_mutex) {
            return _credentials.length;
        }
    }

    // ──────────────────────────────────────
    //  Policies
    // ──────────────────────────────────────

    OBSBucketPolicy upsertPolicy(OBSBucketPolicy p) {
        synchronized (_mutex) {
            _policies[p.policyId] = p;
            return p;
        }
    }

    OBSBucketPolicy getPolicy(string policyId) {
        synchronized (_mutex) {
            if (auto p = policyId in _policies)
                return *p;
            return OBSBucketPolicy.init;
        }
    }

    bool hasPolicy(string policyId) {
        synchronized (_mutex) {
            return (policyId in _policies) !is null;
        }
    }

    OBSBucketPolicy[] listPolicies(string bucketId) {
        synchronized (_mutex) {
            OBSBucketPolicy[] result;
            foreach (ref p; _policies) {
                if (p.bucketId == bucketId) result ~= p;
            }
            return result;
        }
    }

    bool removePolicy(string policyId) {
        synchronized (_mutex) {
            if (policyId in _policies) {
                _policies.remove(policyId);
                return true;
            }
            return false;
        }
    }

    /// Remove all policies for a bucket
    size_t removePoliciesByBucket(string bucketId) {
        synchronized (_mutex) {
            string[] toRemove;
            foreach (k, ref p; _policies) {
                if (p.bucketId == bucketId)
                    toRemove ~= k;
            }
            foreach (k; toRemove)
                _policies.remove(k);
            return toRemove.length;
        }
    }

    size_t policyCount() {
        synchronized (_mutex) {
            return _policies.length;
        }
    }

    // ──────────────────────────────────────
    //  Versions
    // ──────────────────────────────────────

    void addVersion(OBSObjectVersion v) {
        synchronized (_mutex) {
            auto k = objectKey(v.bucketId, v.key);
            _versions[k] ~= v;
        }
    }

    OBSObjectVersion[] listVersions(string bucketId, string key) {
        synchronized (_mutex) {
            auto k = objectKey(bucketId, key);
            if (auto p = k in _versions)
                return *p;
            return [];
        }
    }

    // ──────────────────────────────────────
    //  Metrics
    // ──────────────────────────────────────

    OBSMetrics globalMetrics() {
        synchronized (_mutex) {
            OBSMetrics m;
            m.totalBuckets = _buckets.length;
            foreach (ref b; _buckets) {
                if (b.status == OBSBucketStatus.active) m.activeBuckets++;
            }
            foreach (ref o; _objects) {
                if (o.status == OBSObjectStatus.active) {
                    m.totalObjects++;
                    m.totalStorageBytes += o.sizeBytes;
                }
            }
            m.totalCredentials = _credentials.length;
            m.totalPolicies = _policies.length;
            return m;
        }
    }
}
