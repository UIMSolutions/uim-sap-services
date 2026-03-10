module uim.sap.obs.models.bucket;

import std.datetime : Clock, SysTime;

import vibe.data.json : Json;

import uim.sap.obs.enumerations;

@safe:

/// Object store bucket (S3 bucket / Azure container / GCS bucket)
struct OBSBucket {
    string bucketId;
    string name;
    string description;
    OBSProvider provider = OBSProvider.aws;
    OBSBucketStatus status = OBSBucketStatus.active;
    OBSStorageClass storageClass = OBSStorageClass.standard;
    OBSAccessLevel accessLevel = OBSAccessLevel.private_;
    OBSReplicationMode replication = OBSReplicationMode.singleRegion;
    string region;
    bool versioningEnabled;
    bool encryptionEnabled = true;
    size_t objectCount;
    size_t totalSizeBytes;
    string ownerId;
    string[string] tags;
    string[string] metadata;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        import std.conv : to;
        Json j = Json.emptyObject;
        j["bucket_id"] = bucketId;
        j["name"] = name;
        j["description"] = description;
        j["provider"] = cast(string) provider;
        j["status"] = cast(string) status;
        j["storage_class"] = cast(string) storageClass;
        j["access_level"] = cast(string) accessLevel;
        j["replication"] = cast(string) replication;
        j["region"] = region;
        j["versioning_enabled"] = versioningEnabled;
        j["encryption_enabled"] = encryptionEnabled;
        j["object_count"] = objectCount.to!long;
        j["total_size_bytes"] = totalSizeBytes.to!long;
        j["owner_id"] = ownerId;
        if (tags.length > 0) {
            Json t = Json.emptyObject;
            foreach (k, v; tags) t[k] = v;
            j["tags"] = t;
        }
        if (metadata.length > 0) {
            Json m = Json.emptyObject;
            foreach (k, v; metadata) m[k] = v;
            j["metadata"] = m;
        }
        j["created_at"] = createdAt.toISOExtString();
        j["updated_at"] = updatedAt.toISOExtString();
        return j;
    }
}

OBSBucket bucketFromJson(string bucketId, Json req) {
    OBSBucket b;
    b.bucketId = bucketId;
    b.createdAt = Clock.currTime();
    b.updatedAt = b.createdAt;

    if ("name" in req && req["name"].isString)
        b.name = req["name"].get!string;
    else
        b.name = bucketId;
    if ("description" in req && req["description"].isString)
        b.description = req["description"].get!string;
    if ("provider" in req && req["provider"].isString)
        b.provider = parseProvider(req["provider"].get!string);
    if ("storage_class" in req && req["storage_class"].isString)
        b.storageClass = parseStorageClass(req["storage_class"].get!string);
    if ("access_level" in req && req["access_level"].isString)
        b.accessLevel = parseAccessLevel(req["access_level"].get!string);
    if ("replication" in req && req["replication"].isString)
        b.replication = parseReplicationMode(req["replication"].get!string);
    if ("region" in req && req["region"].isString)
        b.region = req["region"].get!string;
    if ("versioning_enabled" in req && req["versioning_enabled"].type == Json.Type.bool_)
        b.versioningEnabled = req["versioning_enabled"].get!bool;
    if ("encryption_enabled" in req && req["encryption_enabled"].type == Json.Type.bool_)
        b.encryptionEnabled = req["encryption_enabled"].get!bool;
    if ("owner_id" in req && req["owner_id"].isString)
        b.ownerId = req["owner_id"].get!string;
    if ("tags" in req && req["tags"].type == Json.Type.object) {
        foreach (string k, v; req["tags"])
            if (v.isString) b.tags[k] = v.get!string;
    }
    if ("metadata" in req && req["metadata"].type == Json.Type.object) {
        foreach (string k, v; req["metadata"])
            if (v.isString) b.metadata[k] = v.get!string;
    }
    return b;
}

private OBSProvider parseProvider(string s) {
    switch (s) {
        case "aws": return OBSProvider.aws;
        case "azure": return OBSProvider.azure;
        case "gcp": return OBSProvider.gcp;
        default: return OBSProvider.aws;
    }
}

private OBSStorageClass parseStorageClass(string s) {
    switch (s) {
        case "STANDARD": return OBSStorageClass.standard;
        case "NEARLINE": return OBSStorageClass.nearline;
        case "COLDLINE": return OBSStorageClass.coldline;
        case "ARCHIVE": return OBSStorageClass.archive;
        default: return OBSStorageClass.standard;
    }
}

private OBSAccessLevel parseAccessLevel(string s) {
    switch (s) {
        case "private": return OBSAccessLevel.private_;
        case "read-only": return OBSAccessLevel.readOnly;
        case "read-write": return OBSAccessLevel.readWrite;
        default: return OBSAccessLevel.private_;
    }
}

private OBSReplicationMode parseReplicationMode(string s) {
    switch (s) {
        case "none": return OBSReplicationMode.none;
        case "single-region": return OBSReplicationMode.singleRegion;
        case "multi-region": return OBSReplicationMode.multiRegion;
        default: return OBSReplicationMode.singleRegion;
    }
}
