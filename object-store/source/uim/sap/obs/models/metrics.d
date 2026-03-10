module uim.sap.obs.models.metrics;

import vibe.data.json : Json;

@safe:

/// Aggregate metrics for the object store
struct OBSMetrics {
    size_t totalBuckets;
    size_t activeBuckets;
    size_t totalObjects;
    size_t totalStorageBytes;
    size_t totalCredentials;
    size_t totalPolicies;

    Json toJson() const {
        import std.conv : to;
        Json j = Json.emptyObject;
        j["total_buckets"] = totalBuckets.to!long;
        j["active_buckets"] = activeBuckets.to!long;
        j["total_objects"] = totalObjects.to!long;
        j["total_storage_bytes"] = totalStorageBytes.to!long;
        j["total_credentials"] = totalCredentials.to!long;
        j["total_policies"] = totalPolicies.to!long;
        return j;
    }
}
