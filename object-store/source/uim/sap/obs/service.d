module uim.sap.obs.service;

import std.datetime : Clock, dur;

import vibe.data.json : Json;

import uim.sap.obs.config;
import uim.sap.obs.enumerations;
import uim.sap.obs.exceptions;
import uim.sap.obs.helpers;
import uim.sap.obs.models;
import uim.sap.obs.store;

/**
 * Main service class for Object Store on SAP BTP.
 *
 * Manages object store buckets (AWS S3 / Azure Blob / GCS),
 * object creation, upload, download, deletion, versioning,
 * secure credential issuance, and bucket policies.
 */
class OBSService : SAPService {
    mixin(SAPServiceTemplate!OBSService);

    private OBSStore _store;
    private OBSConfig _config;

    this(OBSConfig config) {
        super(config);
        _config = config;
        _store = new OBSStore;
    }

    @property OBSConfig config() { return _config; }

    override Json health() {
        Json info = super.health();
        auto m = _store.globalMetrics();
        info["buckets"] = cast(long) m.totalBuckets;
        info["objects"] = cast(long) m.totalObjects;
        return info;
    }

    override Json ready() {
        Json info = super.ready();
        info["buckets"] = cast(long) _store.bucketCount();
        return info;
    }

    Json getMetrics() {
        return _store.globalMetrics().toJson();
    }

    // ══════════════════════════════════════
    //  Bucket Management
    // ══════════════════════════════════════

    /// Create a new object store bucket
    Json createBucket(Json req) {
        if (_store.bucketCount() >= _config.maxBuckets)
            throw new OBSQuotaExceededException("buckets", _config.maxBuckets);

        string bucketId = generateBucketId();
        OBSBucket b = bucketFromJson(bucketId, req);

        // Validate bucket name
        if (!isValidBucketName(b.name))
            throw new OBSValidationException(
                "Invalid bucket name: must be 3-63 chars, alphanumeric, hyphens, dots");

        // Check for duplicate name
        if (_store.hasBucketByName(b.name))
            throw new OBSConflictException("Bucket", b.name);

        // Apply defaults from config
        if (b.region.length == 0)
            b.region = _config.defaultRegion;
        if (b.versioningEnabled == false && _config.defaultVersioning)
            b.versioningEnabled = true;

        _store.upsertBucket(b);

        // Automatically issue secure credentials for the bucket
        auto cred = issueCredentials(bucketId, b.provider, b.region);

        Json result = b.toJson();
        result["credentials"] = cred;
        return result;
    }

    Json getBucket(string bucketId) {
        if (!_store.hasBucket(bucketId))
            throw new OBSNotFoundException("Bucket", bucketId);

        OBSBucket b = _store.getBucket(bucketId);
        // Refresh counts
        b.objectCount = _store.objectCountForBucket(bucketId);
        b.totalSizeBytes = _store.totalSizeForBucket(bucketId);
        return b.toJson();
    }

    Json listBuckets() {
        auto buckets = _store.listBuckets();
        Json arr = Json.emptyArray;
        foreach (ref b; buckets) {
            b.objectCount = _store.objectCountForBucket(b.bucketId);
            b.totalSizeBytes = _store.totalSizeForBucket(b.bucketId);
            arr ~= b.toJson();
        }
        Json result = Json.emptyObject;
        result["buckets"] = arr;
        result["total"] = cast(long) buckets.length;
        return result;
    }

    Json updateBucket(string bucketId, Json req) {
        if (!_store.hasBucket(bucketId))
            throw new OBSNotFoundException("Bucket", bucketId);

        OBSBucket b = _store.getBucket(bucketId);
        if ("description" in req && req["description"].isString)
            b.description = req["description"].get!string;
        if ("storage_class" in req && req["storage_class"].isString)
            b.storageClass = parseStorageClassStr(req["storage_class"].get!string);
        if ("access_level" in req && req["access_level"].isString)
            b.accessLevel = parseAccessLevelStr(req["access_level"].get!string);
        if ("replication" in req && req["replication"].isString)
            b.replication = parseReplicationStr(req["replication"].get!string);
        if ("versioning_enabled" in req && req["versioning_enabled"].type == Json.Type.bool_)
            b.versioningEnabled = req["versioning_enabled"].get!bool;
        if ("encryption_enabled" in req && req["encryption_enabled"].type == Json.Type.bool_)
            b.encryptionEnabled = req["encryption_enabled"].get!bool;
        if ("tags" in req && req["tags"].type == Json.Type.object) {
            b.tags = typeof(b.tags).init;
            foreach (string k, v; req["tags"])
                if (v.isString) b.tags[k] = v.get!string;
        }
        b.updatedAt = Clock.currTime();
        _store.upsertBucket(b);
        return b.toJson();
    }

    Json deleteBucket(string bucketId) {
        if (!_store.hasBucket(bucketId))
            throw new OBSNotFoundException("Bucket", bucketId);

        // Remove all objects, credentials, and policies
        _store.removeObjectsByBucket(bucketId);
        _store.revokeCredentialsByBucket(bucketId);
        _store.removePoliciesByBucket(bucketId);
        _store.removeBucket(bucketId);

        Json result = Json.emptyObject;
        result["status"] = "deleted";
        result["bucket_id"] = bucketId;
        return result;
    }

    Json suspendBucket(string bucketId) {
        if (!_store.hasBucket(bucketId))
            throw new OBSNotFoundException("Bucket", bucketId);
        OBSBucket b = _store.getBucket(bucketId);
        b.status = OBSBucketStatus.suspended;
        b.updatedAt = Clock.currTime();
        _store.upsertBucket(b);
        Json result = Json.emptyObject;
        result["status"] = "suspended";
        result["bucket_id"] = bucketId;
        return result;
    }

    // ══════════════════════════════════════
    //  Object Operations (Upload / Download / Delete)
    // ══════════════════════════════════════

    /// Upload (create/overwrite) an object in a bucket
    Json uploadObject(string bucketId, Json req) {
        if (!_store.hasBucket(bucketId))
            throw new OBSNotFoundException("Bucket", bucketId);

        OBSBucket bkt = _store.getBucket(bucketId);
        if (bkt.status != OBSBucketStatus.active)
            throw new OBSValidationException("Bucket is not active");

        // Check object count quota
        if (_store.objectCountForBucket(bucketId) >= _config.maxObjectsPerBucket)
            throw new OBSQuotaExceededException("objects per bucket", _config.maxObjectsPerBucket);

        string key = getRequiredString(req, "key");
        if (!isValidObjectKey(key))
            throw new OBSValidationException("Invalid object key");

        string objectId = generateObjectId();
        OBSStoredObject obj = objectFromJson(objectId, bucketId, req);
        obj.etag = computeETag(obj.contentBase64);

        // Check size limit
        if (obj.sizeBytes > _config.maxObjectSizeBytes) {
            import std.conv : to;
            throw new OBSQuotaExceededException("object size bytes", _config.maxObjectSizeBytes);
        }

        // Check bucket storage limit
        size_t currentSize = _store.totalSizeForBucket(bucketId);
        if (currentSize + obj.sizeBytes > _config.maxBucketStorageBytes)
            throw new OBSQuotaExceededException("bucket storage bytes", _config.maxBucketStorageBytes);

        // Handle versioning
        if (bkt.versioningEnabled) {
            obj.versionId = generateVersionId();
            // If object already exists, mark old as non-latest
            if (_store.hasObject(bucketId, key)) {
                auto existing = _store.getObject(bucketId, key);
                // Store previous version
                OBSObjectVersion ver;
                ver.versionId = existing.versionId.length > 0 ? existing.versionId : generateVersionId();
                ver.objectId = existing.objectId;
                ver.bucketId = bucketId;
                ver.key = key;
                ver.sizeBytes = existing.sizeBytes;
                ver.etag = existing.etag;
                ver.contentType = existing.contentType;
                ver.isLatest = false;
                ver.isDeleteMarker = false;
                ver.createdAt = existing.createdAt;
                _store.addVersion(ver);
            }
        }

        _store.upsertObject(obj);
        return obj.toJson();
    }

    /// Download an object (returns metadata + content)
    Json downloadObject(string bucketId, string key) {
        if (!_store.hasBucket(bucketId))
            throw new OBSNotFoundException("Bucket", bucketId);
        if (!_store.hasObject(bucketId, key))
            throw new OBSNotFoundException("Object", key);

        auto obj = _store.getObject(bucketId, key);
        if (obj.status != OBSObjectStatus.active)
            throw new OBSNotFoundException("Object", key);
        return obj.toJsonWithContent();
    }

    /// Get object metadata (no content)
    Json headObject(string bucketId, string key) {
        if (!_store.hasBucket(bucketId))
            throw new OBSNotFoundException("Bucket", bucketId);
        if (!_store.hasObject(bucketId, key))
            throw new OBSNotFoundException("Object", key);

        auto obj = _store.getObject(bucketId, key);
        return obj.toJson();
    }

    /// List objects in a bucket, optionally filtered by prefix
    Json listObjects(string bucketId, string prefix = "") {
        if (!_store.hasBucket(bucketId))
            throw new OBSNotFoundException("Bucket", bucketId);

        OBSStoredObject[] objects;
        if (prefix.length > 0)
            objects = _store.listObjectsByPrefix(bucketId, prefix);
        else
            objects = _store.listObjects(bucketId);

        Json arr = Json.emptyArray;
        foreach (ref o; objects) arr ~= o.toJson();
        Json result = Json.emptyObject;
        result["bucket_id"] = bucketId;
        result["objects"] = arr;
        result["total"] = cast(long) objects.length;
        if (prefix.length > 0) result["prefix"] = prefix;
        return result;
    }

    /// Delete an object from a bucket
    Json deleteObject(string bucketId, string key) {
        if (!_store.hasBucket(bucketId))
            throw new OBSNotFoundException("Bucket", bucketId);
        if (!_store.hasObject(bucketId, key))
            throw new OBSNotFoundException("Object", key);

        // If versioning, add a delete marker instead of removing
        OBSBucket bkt = _store.getBucket(bucketId);
        if (bkt.versioningEnabled) {
            auto existing = _store.getObject(bucketId, key);
            OBSObjectVersion delMarker;
            delMarker.versionId = generateVersionId();
            delMarker.objectId = existing.objectId;
            delMarker.bucketId = bucketId;
            delMarker.key = key;
            delMarker.isLatest = true;
            delMarker.isDeleteMarker = true;
            delMarker.createdAt = Clock.currTime();
            _store.addVersion(delMarker);
        }

        _store.removeObject(bucketId, key);

        Json result = Json.emptyObject;
        result["status"] = "deleted";
        result["bucket_id"] = bucketId;
        result["key"] = key;
        return result;
    }

    /// List object versions
    Json listObjectVersions(string bucketId, string key) {
        if (!_store.hasBucket(bucketId))
            throw new OBSNotFoundException("Bucket", bucketId);

        auto versions = _store.listVersions(bucketId, key);
        Json arr = Json.emptyArray;
        foreach (ref v; versions) arr ~= v.toJson();
        Json result = Json.emptyObject;
        result["bucket_id"] = bucketId;
        result["key"] = key;
        result["versions"] = arr;
        result["total"] = cast(long) versions.length;
        return result;
    }

    // ══════════════════════════════════════
    //  Credential Management (Secure Access)
    // ══════════════════════════════════════

    /// Issue new credentials for a bucket
    Json createCredentials(string bucketId, Json req) {
        if (!_store.hasBucket(bucketId))
            throw new OBSNotFoundException("Bucket", bucketId);

        OBSBucket bkt = _store.getBucket(bucketId);
        auto cred = issueCredentials(bucketId, bkt.provider, bkt.region);

        string description = "";
        if ("description" in req && req["description"].isString)
            description = req["description"].get!string;

        // Update description if provided
        if (description.length > 0) {
            auto stored = _store.getCredential(cred["credential_id"].get!string);
            stored.description = description;
            _store.storeCredential(stored);
            cred["description"] = description;
        }

        return cred;
    }

    Json listCredentials(string bucketId) {
        if (!_store.hasBucket(bucketId))
            throw new OBSNotFoundException("Bucket", bucketId);

        auto creds = _store.listCredentials(bucketId);
        Json arr = Json.emptyArray;
        foreach (ref c; creds) arr ~= c.toJson();
        Json result = Json.emptyObject;
        result["bucket_id"] = bucketId;
        result["credentials"] = arr;
        result["total"] = cast(long) creds.length;
        return result;
    }

    Json revokeCredentials(string credentialId) {
        if (!_store.hasCredential(credentialId))
            throw new OBSNotFoundException("Credential", credentialId);

        _store.revokeCredential(credentialId);
        Json result = Json.emptyObject;
        result["status"] = "revoked";
        result["credential_id"] = credentialId;
        return result;
    }

    // ══════════════════════════════════════
    //  Policy Management
    // ══════════════════════════════════════

    Json createPolicy(string bucketId, Json req) {
        if (!_store.hasBucket(bucketId))
            throw new OBSNotFoundException("Bucket", bucketId);

        string policyId = generatePolicyId();
        OBSBucketPolicy p = policyFromJson(policyId, bucketId, req);
        _store.upsertPolicy(p);
        return p.toJson();
    }

    Json getPolicy(string policyId) {
        if (!_store.hasPolicy(policyId))
            throw new OBSNotFoundException("Policy", policyId);
        return _store.getPolicy(policyId).toJson();
    }

    Json listPolicies(string bucketId) {
        if (!_store.hasBucket(bucketId))
            throw new OBSNotFoundException("Bucket", bucketId);

        auto policies = _store.listPolicies(bucketId);
        Json arr = Json.emptyArray;
        foreach (ref p; policies) arr ~= p.toJson();
        Json result = Json.emptyObject;
        result["bucket_id"] = bucketId;
        result["policies"] = arr;
        result["total"] = cast(long) policies.length;
        return result;
    }

    Json deletePolicy(string policyId) {
        if (!_store.hasPolicy(policyId))
            throw new OBSNotFoundException("Policy", policyId);

        _store.removePolicy(policyId);
        Json result = Json.emptyObject;
        result["status"] = "deleted";
        result["policy_id"] = policyId;
        return result;
    }

    // ══════════════════════════════════════
    //  Private Helpers
    // ══════════════════════════════════════

    /// Issue secure credentials for a bucket and return JSON
    private Json issueCredentials(string bucketId, OBSProvider provider, string region) {
        auto now = Clock.currTime();
        OBSCredential cred;
        cred.credentialId = generateCredentialId();
        cred.bucketId = bucketId;
        cred.accessKeyId = generateAccessKeyId();
        cred.secretAccessKey = generateSecretAccessKey();
        cred.status = OBSCredentialStatus.active;
        cred.provider = provider;
        cred.region = region;
        cred.endpoint = providerEndpoint(provider, region);
        cred.issuedAt = now;
        cred.expiresAt = now + dur!"hours"(24);
        _store.storeCredential(cred);
        return cred.toJsonWithSecret();
    }

    private static string getRequiredString(Json req, string key) {
        if (key in req && req[key].isString) {
            string v = req[key].get!string;
            if (v.length > 0) return v;
        }
        throw new OBSValidationException("Missing required parameter: " ~ key);
    }

    private static OBSStorageClass parseStorageClassStr(string s) {
        switch (s) {
            case "STANDARD": return OBSStorageClass.standard;
            case "NEARLINE": return OBSStorageClass.nearline;
            case "COLDLINE": return OBSStorageClass.coldline;
            case "ARCHIVE": return OBSStorageClass.archive;
            default: return OBSStorageClass.standard;
        }
    }

    private static OBSAccessLevel parseAccessLevelStr(string s) {
        switch (s) {
            case "private": return OBSAccessLevel.private_;
            case "read-only": return OBSAccessLevel.readOnly;
            case "read-write": return OBSAccessLevel.readWrite;
            default: return OBSAccessLevel.private_;
        }
    }

    private static OBSReplicationMode parseReplicationStr(string s) {
        switch (s) {
            case "none": return OBSReplicationMode.none;
            case "single-region": return OBSReplicationMode.singleRegion;
            case "multi-region": return OBSReplicationMode.multiRegion;
            default: return OBSReplicationMode.singleRegion;
        }
    }
}
